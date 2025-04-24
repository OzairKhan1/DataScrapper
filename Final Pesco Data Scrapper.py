import streamlit as st
import pandas as pd
import requests
from bs4 import BeautifulSoup
import io
import time
from requests.adapters import HTTPAdapter, Retry
import matplotlib.pyplot as plt

st.set_page_config(page_title="🔍 PESCO Bill Extractor", layout="centered")

# ---------------------------------------------
# Streamlit UI
# ---------------------------------------------
st.markdown("""
    <style>
        .main {
            background-image: url("https://images.unsplash.com/photo-1532619187608-e5375cab36c9?ixlib=rb-4.0.3&auto=format&fit=crop&w=1950&q=80");
            background-size: cover;
            background-attachment: fixed;
        }

        .designer {
            text-align: center;
            font-size: 26px;
            color: #ffffff;
            font-weight: bold;
            margin-top: 20px;
            font-family: 'Arial', sans-serif;
        }

        .center-title {
            text-align: center;
            color: #ffffff;
            background-color: rgba(0, 0, 0, 0.6);
            padding: 1rem;
            border-radius: 10px;
            font-family: 'Arial', sans-serif;
            margin-top: 10px;
        }

        .dedication {
            text-align: center;
            font-size: 18px;
            margin-top: -10px;
            color: #dddddd;
        }
    </style>

    <div class="designer">👨‍💻 Designed by Engr. Ozair Khan</div>

    <div class="center-title">
        <h1>🔍 PESCO Bill Extractor Tool</h1> 
        <p class="dedication">🎓 Dedicated to Engr. Bilal Ahmad</p>
    </div>
""", unsafe_allow_html=True)

uploaded_file = st.file_uploader("📤 Upload your Excel file", type=["xlsx", "xls"])
if uploaded_file:
    try:
        df = pd.read_excel(uploaded_file, dtype=str)
        df = df.where(pd.notnull(df), "")  # Clean NaN
        st.success("✅ File uploaded successfully!")
        st.dataframe(df.astype(str))  # Avoid ArrowTypeError

        selected_col = st.selectbox("1️⃣ Select column with reference numbers:", df.columns)

        target_col = st.selectbox("2️⃣ Select output column for Customer IDs:",
                                  df.columns.tolist() + ["➕ Create new column..."])

        if target_col == "➕ Create new column...":
            new_col_name = st.text_input("Enter name for new column:")
            if new_col_name:
                if new_col_name not in df.columns:
                    df[new_col_name] = ""
                    target_col = new_col_name
                else:
                    st.warning("⚠️ Column already exists. Please choose another name.")
                    st.stop()

        if st.checkbox("⚠️ I understand this will modify the selected column with extracted data. Proceed?"):
            if st.button("🚀 Start Extracting Customer IDs"):

                with st.spinner("🔄 Extracting from PESCO website..."):

                    session = requests.Session()
                    retries = Retry(
                        total=5,
                        backoff_factor=1,
                        status_forcelist=[429, 502, 503, 504]
                    )
                    adapter = HTTPAdapter(max_retries=retries)
                    session.mount("https://", adapter)
                    session.mount("http://", adapter)

                    success_count = 0
                    fail_count = 0

                    for i, (index, row) in enumerate(df.iterrows(), start=1):
                        ref_raw = row[selected_col]

                        try:
                            ref_num = str(int(float(ref_raw))).zfill(14)
                        except:
                            df.at[index, target_col] = ""
                            fail_count += 1
                            continue

                        st.info(f"🔎 [{i}] Extracting for Account: {ref_raw}")

                        try:
                            url = "https://www.pescobill.net/view-pesco-bill/"
                            session.get(url, timeout=(5, 20))  # slow net handling

                            payload = {
                                'reference': ref_num,
                                'submit': 'Check Electricity Bill'
                            }

                            response = session.post(url, data=payload, timeout=(5, 20))
                            soup = BeautifulSoup(response.text, 'html.parser')
                            open_bill_button = soup.find('button', string='Open My Bill')

                            if open_bill_button:
                                form = open_bill_button.find_parent('form')
                                if form:
                                    action_url = form.get('action')
                                    full_url = requests.compat.urljoin(url, action_url)
                                    bill_response = session.post(full_url, data={}, timeout=(5, 20))
                                    bill_soup = BeautifulSoup(bill_response.text, 'html.parser')
                                    row = bill_soup.find('tr', class_='fontsize content')

                                    if row:
                                        consumer_id_td = row.find_all('td')[0]
                                        consumer_id = consumer_id_td.text.strip()
                                        df.at[index, target_col] = consumer_id
                                        success_count += 1
                                    else:
                                        df.at[index, target_col] = ""
                                        fail_count += 1
                                else:
                                    df.at[index, target_col] = ""
                                    fail_count += 1
                            else:
                                df.at[index, target_col] = ""
                                fail_count += 1
                        except Exception:
                            df.at[index, target_col] = ""
                            fail_count += 1
                            continue

                st.success("✅ Completed extraction!")
                st.subheader("📊 Extraction Statistics")

                fig, ax = plt.subplots(figsize=(4, 4))  # Smaller width
                bars = ax.bar(["Success", "Failed"], [success_count, fail_count], color=["lightgreen", "cyan"], width=0.4)
                ax.set_ylabel("Count")

                # Add numbers on top of each bar
                for bar in bars:
                    height = bar.get_height()
                    ax.text(bar.get_x() + bar.get_width() / 2.0, height + 0.5, f'{int(height)}',
                            ha='center', va='bottom', fontsize=10, fontweight='bold', color='black')

                st.pyplot(fig)

                st.write("🔍 Final Updated Data:")
                # st.dataframe(df.astype(str))

                @st.cache_data
                def to_excel(df: pd.DataFrame):
                    output = io.BytesIO()
                    with pd.ExcelWriter(output, engine="openpyxl") as writer:
                        df.to_excel(writer, index=False, sheet_name="Results")
                    return output.getvalue()

                excel_data = to_excel(df)
                st.download_button(
                    label="📥 Download Updated Excel",
                    data=excel_data,
                    file_name="updated_pesco_ids.xlsx",
                    mime="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                )

    except Exception as e:
        st.error(f"❌ Error reading file: {e}")

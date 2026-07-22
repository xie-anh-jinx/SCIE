"""
Upload SCIE Data & Dataset to Hugging Face Storage Bucket (Kotarominami/SCIE)
"""
import os
import sys
from huggingface_hub import HfApi

TOKEN = os.getenv("HF_TOKEN")

def main():
    if not TOKEN:
        print("----------------------------------------------------------------------")
        print("❌ KUNCI TOKEN HUGGING FACE BELUM DIMASUKKAN")
        print("----------------------------------------------------------------------")
        print("Untuk mengunggah file ke Hugging Face Bucket (Kotarominami/SCIE):")
        print("1. Buka https://huggingface.co/settings/tokens")
        print("2. Buat Access Token baru dengan role 'Write'")
        print("3. Jalankan perintah di terminal:")
        print("   export HF_TOKEN='hf_xxxxxxx'")
        print("   poetry run python upload_to_hf.py")
        print("----------------------------------------------------------------------")
        sys.exit(1)

    api = HfApi(token=TOKEN)
    data_dir = "/home/kotaromiyabi/SCIE/data"

    if not os.path.exists(data_dir):
        os.makedirs(data_dir, exist_ok=True)

    print(f"Mengunggah seluruh file dari {data_dir} ke hf://buckets/Kotarominami/SCIE ...")
    try:
        api.upload_folder(
            folder_path=data_dir,
            repo_id="Kotarominami/SCIE",
            repo_type="dataset", # Or bucket storage
        )
        print("✅ BERHASIL MENGUNGGAH KE HUGGING FACE BUCKET!")
    except Exception as e:
        print(f" Gagal mengunggah: {e}")

if __name__ == "__main__":
    main()

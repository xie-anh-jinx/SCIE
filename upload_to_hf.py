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

    repo_id = "Kotarominami/SCIE"

    print(f"1. Memastikan repositori {repo_id} tersedia di Hugging Face...")
    try:
        api.create_repo(repo_id=repo_id, repo_type="dataset", private=True, exist_ok=True)
        print(f"✓ Repositori dataset {repo_id} siap.")
    except Exception as e:
        print(f"Catatan repositori: {e}")

    print(f"2. Mengunggah berkas dataset dari {data_dir} ke Hugging Face...")
    try:
        api.upload_folder(
            folder_path=data_dir,
            repo_id=repo_id,
            repo_type="dataset",
        )
        print("✅ BERHASIL MENGUNGGAH SELURUH DATASET KE HUGGING FACE!")
        print(f"🔗 Akses dataset Anda di: https://huggingface.co/datasets/{repo_id}")
    except Exception as e:
        print(f"❌ Gagal mengunggah: {e}")


if __name__ == "__main__":
    main()

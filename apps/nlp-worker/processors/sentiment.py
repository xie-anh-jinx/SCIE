"""
Sentiment Analysis Processor — Supports HuggingFace IndoBERT / Lexicon fallback.
"""
import re
import structlog

log = structlog.get_logger()

# Lexicon dictionaries for fast Indonesian sentiment scoring
POSITIVE_WORDS = {
    "bagus", "baik", "mantap", "hebat", "kemajuan", "pesat", "sukses", "unggul",
    "mendukung", "positif", "solusi", "terbaik", "inovasi", "berhasil", "apresiasi",
    "senang", "untung", "efisien", "transparan", "terintegrasi", "pembaharuan", "optimis"
}

NEGATIVE_WORDS = {
    "buruk", "jelek", "gagal", "rugi", "korupsi", "hoaks", "disinformasi", "krisis",
    "kecewa", "lambat", "masalah", "parah", "bahaya", "ancaman", "rusak", "kontroversi",
    "rugikan", "negatif", "menolak", "kejahatan", "penipuan", "keluhan", "turun"
}


def analyze_sentiment(text: str) -> tuple[str, float]:
    """
    Analyze text sentiment returning (label, score).
    Score ranges from -1.0 (most negative) to +1.0 (most positive).
    """
    if not text:
        return "neutral", 0.0

    words = re.findall(r"\w+", text.lower())
    if not words:
        return "neutral", 0.0

    pos_count = sum(1 for w in words if w in POSITIVE_WORDS)
    neg_count = sum(1 for w in words if w in NEGATIVE_WORDS)

    total_matched = pos_count + neg_count
    if total_matched == 0:
        return "neutral", 0.0

    score = round((pos_count - neg_count) / max(total_matched, 1), 2)

    if score > 0.15:
        label = "positive"
    elif score < -0.15:
        label = "negative"
    else:
        label = "neutral"

    return label, score

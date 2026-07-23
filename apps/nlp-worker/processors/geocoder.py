"""
Indonesian NLP Geocoder & Layer Classifier Module.
Maps Indonesian entities, cities, provinces, and strategic areas to precise coordinates (Latitude/Longitude),
and categorizes posts into 7 Situational Intelligence Layers.
"""

# Dictionary of Indonesian Locations (Provinces, Major Cities, Strategic Sites) with Coordinates (Lat, Lon)
INDONESIA_GEOLOCATION_MAP = {
    # ── DKI Jakarta & Metro ──
    "jakarta": (-6.2088, 106.8456, "DKI Jakarta"),
    "dki jakarta": (-6.2088, 106.8456, "DKI Jakarta"),
    "kebayoran lama": (-6.2425, 106.7801, "DKI Jakarta"),
    "jakarta selatan": (-6.2615, 106.8106, "DKI Jakarta"),
    "jakarta pusat": (-6.1805, 106.8284, "DKI Jakarta"),
    "jakarta timur": (-6.2250, 106.9004, "DKI Jakarta"),
    "jakarta barat": (-6.1683, 106.7589, "DKI Jakarta"),
    "jakarta utara": (-6.1214, 106.8837, "DKI Jakarta"),

    # ── Jawa ──
    "bandung": (-6.9175, 107.6191, "Jawa Barat"),
    "jawa barat": (-6.9175, 107.6191, "Jawa Barat"),
    "bogor": (-6.5971, 106.7974, "Jawa Barat"),
    "depok": (-6.4025, 106.7942, "Jawa Barat"),
    "bekasi": (-6.2383, 106.9756, "Jawa Barat"),
    "semarang": (-6.9667, 110.4167, "Jawa Tengah"),
    "jawa tengah": (-6.9667, 110.4167, "Jawa Tengah"),
    "solo": (-7.5755, 110.8243, "Jawa Tengah"),
    "surakarta": (-7.5755, 110.8243, "Jawa Tengah"),
    "yogyakarta": (-7.7956, 110.3695, "DI Yogyakarta"),
    "jogja": (-7.7956, 110.3695, "DI Yogyakarta"),
    "surabaya": (-7.2575, 112.7521, "Jawa Timur"),
    "jawa timur": (-7.2575, 112.7521, "Jawa Timur"),
    "malang": (-7.9666, 112.6326, "Jawa Timur"),
    "banten": (-6.1200, 106.1500, "Banten"),
    "tangerang": (-6.1783, 106.6300, "Banten"),
    "cilegon": (-6.0174, 106.0538, "Banten"),

    # ── Sumatera ──
    "aceh": (4.6951, 96.7494, "Aceh"),
    "banda aceh": (5.5483, 95.3238, "Aceh"),
    "gayo lues": (3.9554, 97.3514, "Aceh"),
    "sabang": (5.8933, 95.3214, "Aceh"),
    "medan": (3.5952, 98.6722, "Sumatera Utara"),
    "sumatera utara": (3.5952, 98.6722, "Sumatera Utara"),
    "padang": (-0.9471, 100.4172, "Sumatera Barat"),
    "sumatera barat": (-0.9471, 100.4172, "Sumatera Barat"),
    "riau": (0.5071, 101.4478, "Riau"),
    "pekanbaru": (0.5071, 101.4478, "Riau"),
    "batam": (1.1301, 104.0529, "Kepulauan Riau"),
    "kepulauan riau": (3.9456, 108.1428, "Kepulauan Riau"),
    "natuna": (3.9456, 108.1428, "Kepulauan Riau"),
    "jambi": (-1.6101, 103.6131, "Jambi"),
    "palembang": (-2.9761, 104.7754, "Sumatera Selatan"),
    "sumatera selatan": (-2.9761, 104.7754, "Sumatera Selatan"),
    "bengkulu": (-3.7928, 102.2608, "Bengkulu"),
    "lampung": (-5.4500, 105.2667, "Lampung"),
    "bandar lampung": (-5.4500, 105.2667, "Lampung"),
    "bangka belitung": (-2.7411, 106.4406, "Bangka Belitung"),

    # ── Kalimantan ──
    "ikn": (-0.9719, 116.7032, "Kalimantan Timur"),
    "ikn nusantara": (-0.9719, 116.7032, "Kalimantan Timur"),
    "nusantara": (-0.9719, 116.7032, "Kalimantan Timur"),
    "balikpapan": (-1.2379, 116.8529, "Kalimantan Timur"),
    "samarinda": (-0.5022, 117.1536, "Kalimantan Timur"),
    "kalimantan timur": (-0.5022, 117.1536, "Kalimantan Timur"),
    "pontianak": (-0.0263, 109.3425, "Kalimantan Barat"),
    "kalimantan barat": (-0.0263, 109.3425, "Kalimantan Barat"),
    "palangkaraya": (-2.2136, 113.9108, "Kalimantan Tengah"),
    "kalimantan tengah": (-2.2136, 113.9108, "Kalimantan Tengah"),
    "banjarmasin": (-3.3194, 114.5908, "Kalimantan Selatan"),
    "kalimantan selatan": (-3.3194, 114.5908, "Kalimantan Selatan"),
    "tarakan": (3.3274, 117.5878, "Kalimantan Utara"),
    "kalimantan utara": (3.3274, 117.5878, "Kalimantan Utara"),

    # ── Sulawesi ──
    "makassar": (-5.1477, 119.4327, "Sulawesi Selatan"),
    "sulawesi selatan": (-5.1477, 119.4327, "Sulawesi Selatan"),
    "selayar": (-6.1172, 120.4632, "Sulawesi Selatan"),
    "manado": (1.4748, 124.8428, "Sulawesi Utara"),
    "sulawesi utara": (1.4748, 124.8428, "Sulawesi Utara"),
    "palu": (-0.9003, 119.8779, "Sulawesi Tengah"),
    "sulawesi tengah": (-0.9003, 119.8779, "Sulawesi Tengah"),
    "kendari": (-3.9985, 122.5126, "Sulawesi Tenggara"),
    "sulawesi tenggara": (-3.9985, 122.5126, "Sulawesi Tenggara"),
    "gorontalo": (0.5435, 123.0568, "Gorontalo"),
    "mamuju": (-2.6773, 118.8879, "Sulawesi Barat"),
    "sulawesi barat": (-2.6773, 118.8879, "Sulawesi Barat"),

    # ── Bali, NTB, NTT ──
    "bali": (-8.4095, 115.1889, "Bali"),
    "denpasar": (-8.6705, 115.2126, "Bali"),
    "lombok": (-8.6509, 116.3249, "Nusa Tenggara Barat"),
    "mataram": (-8.5833, 116.1167, "Nusa Tenggara Barat"),
    "ntb": (-8.6509, 116.3249, "Nusa Tenggara Barat"),
    "kupang": (-10.1772, 123.6070, "Nusa Tenggara Timur"),
    "ntt": (-10.1772, 123.6070, "Nusa Tenggara Timur"),
    "labuan bajo": (-8.4539, 119.8728, "Nusa Tenggara Timur"),

    # ── Maluku & Papua ──
    "ambon": (-3.6954, 128.1814, "Maluku"),
    "maluku": (-3.6954, 128.1814, "Maluku"),
    "ternate": (0.7900, 127.3800, "Maluku Utara"),
    "maluku utara": (0.7900, 127.3800, "Maluku Utara"),
    "jayapura": (-2.5489, 140.7180, "Papua"),
    "papua": (-2.5489, 140.7180, "Papua"),
    "timika": (-4.5447, 136.8873, "Papua Tengah"),
    "merauke": (-8.4991, 140.4045, "Papua Selatan"),
    "sorong": (-0.8762, 131.2558, "Papua Barat Daya"),
    "manokwari": (-0.8615, 134.0620, "Papua Barat"),

    # ── Strategic Waterways ──
    "selat malaka": (2.5000, 101.5000, "Kepulauan Riau"),
    "selat sunda": (-5.9000, 105.8000, "Banten"),
    "selat lombok": (-8.4000, 115.7000, "Bali"),
    "laut natuna utara": (4.5000, 108.5000, "Kepulauan Riau"),
}

# Fallback Indonesia Center Coordinate
INDONESIA_DEFAULT_CENTER = (-2.5489, 118.0149, "Indonesia")


def geocode_indonesia_text(text: str, entities: list[str] = None) -> tuple[float, float, str, str]:
    """
    Geocode an Indonesian text entry into (latitude, longitude, location_name, province).
    Checks entities and raw text against the Indonesian geolocation dictionary.
    """
    text_lower = text.lower() if text else ""
    check_list = [e.lower() for e in (entities or [])] + text_lower.split()

    # 1. Direct match on entities or words
    for item in check_list:
        for loc_key, (lat, lon, prov) in INDONESIA_GEOLOCATION_MAP.items():
            if loc_key in item or item == loc_key:
                return lat, lon, loc_key.title(), prov

    # 2. Substring match in full text
    for loc_key, (lat, lon, prov) in INDONESIA_GEOLOCATION_MAP.items():
        if loc_key in text_lower:
            return lat, lon, loc_key.title(), prov

    # 3. Default Indonesia Center fallback
    return INDONESIA_DEFAULT_CENTER[0], INDONESIA_DEFAULT_CENTER[1], "Indonesia", "Nasional"


def classify_indonesia_layer(text: str, topics: list[str] = None) -> str:
    """
    Classify a post into 1 of the 7 Indonesian Situational Awareness Layers:
    - 'konflik': Konflik & Keamanan Wilayah
    - 'hotspot': Hotspots & Disinformasi Publik
    - 'pangkalan': Pangkalan & Obvitnas (TNI / Objek Vital)
    - 'infrastruktur': Infrastruktur & Pemadaman (PLN, Internet, Jalan)
    - 'ekonomi': Ekonomi & Harga Pangan (Sembako, UMR, Inflasi)
    - 'perairan': Perairan & Selat Strategis (Natuna, Selat Malaka)
    - 'bencana': Bencana Alam & BMKG Cuaca (Gempa, Banjir, Erupsi)
    """
    full_text = (text + " " + " ".join(topics or [])).lower()

    if any(k in full_text for k in ["pilkada", "pemilu", "gubernur", "dprd", "politik", "paslon", "kampanye", "kpu", "bawaslu", "partai", "debat", "bupati", "walikota", "pemprov", "pemkot"]):
        return "konflik"
    if any(k in full_text for k in ["gempa", "bmkg", "banjir", "erupsi", "tsunami", "gunung", "karhutla", "longsor", "cuaca"]):
        return "bencana"
    if any(k in full_text for k in ["selat", "perairan", "natuna", "kapal", "laut", "maritim", "nelayan", "ikan"]):
        return "perairan"
    if any(k in full_text for k in ["tni", "pangkalan", "alutsista", "kodam", "polda", "obvitnas", "babinsa", "polri"]):
        return "pangkalan"
    if any(k in full_text for k in ["polisi", "tahanan", "densus", "propaganda", "teror", "konflik", "hukum", "sidang"]):
        return "konflik"
    if any(k in full_text for k in ["pln", "listrik", "internet", "roboh", "terbengkalai", "jalan", "sekolah", "rusak", "kereta"]):
        return "infrastruktur"
    if any(k in full_text for k in ["harga", "ekonomi", "sembako", "pangan", "rupiah", "inflasi", "pasar", "saham", "investasi"]):
        return "ekonomi"

    return "hotspot"


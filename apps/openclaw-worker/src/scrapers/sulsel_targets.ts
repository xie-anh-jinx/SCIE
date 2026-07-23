export const SULSEL_POLITICAL_KEYWORDS = [
  'pilkada sulsel',
  'pilwalkot makassar',
  'gubernur sulsel',
  'dprd sulsel',
  'dprd makassar',
  'pemprov sulsel',
  'bawaslu sulsel',
  'kpu sulsel',
  'kebijakan gubernur',
  'paslon gubernur sulsel',
  'partai politik makassar',
  'kampanye pilkada',
  'isu politik makassar',
];

export const SULSEL_TARGET_KEYWORDS = [
  ...SULSEL_POLITICAL_KEYWORDS,
  'makassar',
  'sulawesi selatan',
  'gowa',
  'maros',
  'parepare',
  'palopo',
  'bone',
  'selayar',
  'kodam XIV hasanuddin',
  'polrestabes makassar',
  'bmkg makassar',
];

export const SULSEL_LOCATION_MAPPINGS: Record<string, { lat: number; lon: number; name: string }> = {
  makassar: { lat: -5.1477, lon: 119.4327, name: 'Makassar' },
  gowa: { lat: -5.2000, lon: 119.4500, name: 'Gowa' },
  maros: { lat: -5.0000, lon: 119.5700, name: 'Maros' },
  parepare: { lat: -4.0133, lon: 119.6244, name: 'Parepare' },
  palopo: { lat: -2.9944, lon: 120.1947, name: 'Palopo' },
  bone: { lat: -4.5386, lon: 120.3250, name: 'Bone' },
  selayar: { lat: -6.1172, lon: 120.4632, name: 'Kepulauan Selayar' },
};

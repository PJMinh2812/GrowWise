enum AgeGroup { young, middle, older }

extension AgeGroupHelper on int {
  AgeGroup get ageGroup {
    if (this <= 8) return AgeGroup.young;
    if (this <= 10) return AgeGroup.middle;
    return AgeGroup.older;
  }
}

typedef CoinRange = ({int min, int max, int defaultVal});

const Map<AgeGroup, CoinRange> ageGroupCoinRanges = {
  AgeGroup.young:  (min: 5,  max: 20, defaultVal: 10),
  AgeGroup.middle: (min: 10, max: 35, defaultVal: 20),
  AgeGroup.older:  (min: 15, max: 50, defaultVal: 25),
};

String taskDifficultyLabel(int coinReward) {
  if (coinReward <= 12) return '⭐ Dễ';
  if (coinReward <= 25) return '⭐⭐ Vừa';
  return '⭐⭐⭐ Khó';
}

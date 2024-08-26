class OnboardingContents {
  final String title;
  final String image;
  final String desc;

  OnboardingContents({
    required this.title,
    required this.image,
    required this.desc,
  });
}

List<OnboardingContents> contents = [
  OnboardingContents(
    title: "Local dialect translation in real-time",
    image: "assets/images/recognition.png",
    desc: "Get real-time drive translations in your local dialect.",
  ),
  OnboardingContents(
    title: "Understand traffic signs",
    image: "assets/images/traffic_sign.jpg",
    desc:
    "Understand most traffic signs in your local dialect.",
  ),
  OnboardingContents(
    title: "Get notified when nearing your destination.",
    image: "assets/images/google-maps-car-logo.jpg",
    desc:
    "Take control of notifications.",
  ),
];
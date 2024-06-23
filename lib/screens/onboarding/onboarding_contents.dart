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
    title: "Real time translation in local dialect",
    image: "assets/images/recognition.png",
    desc: "Get a real time translation of your drive in your local dialect",
  ),
  OnboardingContents(
    title: "Learn about traffic signs",
    image: "assets/images/traffic_sign.jpg",
    desc:
    "Understand most traffic signs in your local dialect.",
  ),
  OnboardingContents(
    title: "Get notified when you are about to get to your destination",
    image: "assets/images/google-maps-car-logo.jpg",
    desc:
    "Take control of notifications.",
  ),
];
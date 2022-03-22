class Movie {
  String title;
  List<String> genre;
  String image;
  double rating;
  String year;

  Movie({required this.title, required this.genre, required this.image, required this.rating, required this.year});

  factory Movie.fromJson(dynamic json) {
    return Movie(
        title: json['title'],
        image: json['image'],
        rating: double.parse(json['rating'].toString()),
        year: json['releaseYear'].toString(),
        genre: List<String>.from(json['genre'].map((item)=> item))
    );
  }
}
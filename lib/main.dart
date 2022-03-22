import 'package:flutter/material.dart';
import 'package:movies/details.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'movie.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => WatchListModel(),
        child: MaterialApp(
          title: 'Flutter Demo',
          initialRoute: '/',
          routes: {
            '/': (context) => MoviesList(),
            '/watchlist': (context) => WatchList()
          },
        )
    );
  }
}



class MoviesList extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movies'),
        actions: [
          IconButton(
            icon: Icon(Icons.watch_later),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WatchList()),
              );
            },
          ),
        ],
      ),
      body: ListDisplay(),
    );
  }

}

class ListDisplay extends StatefulWidget{
  @override
  _ListDisplayState createState() {
    return _ListDisplayState();
  }

}

class _ListDisplayState extends State<ListDisplay>{

  late Future<List<Movie>> futureMovies;

  Future<List<Movie>> fetchMovies() async {

    final http.Response response = await http.get("https://api.androidhive.info/json/movies.json");

    if (response.statusCode == 200) {
      // success, parse json data
      List jsonArray = jsonDecode(response.body);
      List<Movie> movies = jsonArray.map((x)=> Movie.fromJson(x)).toList();
      return movies;
    }
    else{
      throw Exception("Failed to load data");
    }
  }

  @override
  void initState() {
    super.initState();
    this.futureMovies = fetchMovies();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Movie>>(
        future: this.futureMovies,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Movie>? movies = snapshot.data;
            return ListView.builder(
              itemCount: movies?.length,
              itemBuilder: (BuildContext context, int index){
                return Dismissible(
                    key: Key(movies![index].title),
                    onDismissed: (direction){
                      setState(() {
                        movies?.removeAt(index);
                      });
                    },
                    child: GestureDetector(onTap: (){
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Details(movies[index]),));

                    },
                        child: MovieItem(movie: movies[index]))
                );
              },
            );
          }
          else if (snapshot.hasError) {
            return Text("error ${snapshot.error}");
          }
          return Center(
              child:CircularProgressIndicator()
          );
        }
    );
  }
}

class MovieItem extends StatelessWidget {

  final Movie movie;

  MovieItem({ required this.movie});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      height: 120,
      child: Card(
        child: Row(
          children: [
            Image.network(this.movie.image),
            Expanded(
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 5, 5, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        this.movie.title, style: TextStyle(fontWeight: FontWeight.bold),),
                      Text(this.movie.genre.toString()),
                      Row(
                        children: [
                          Consumer<WatchListModel>
                            (builder: (context, watchList, child){
                            bool addedToWatchList = watchList.itemExists(movie);
                            return  IconButton(
                                icon: Icon(
                                  addedToWatchList? Icons.delete :Icons.watch_later,
                                ),
                                onPressed: () {
                                  watchList.itemExists(movie)?
                                  Provider.of<WatchListModel>(context, listen: false).remove(movie):
                                  Provider.of<WatchListModel>(context, listen: false).add(this.movie);
                                }
                            );
                          }),
                          Expanded(
                            child:  Container(
                              alignment: Alignment.centerRight,
                              child: Text(this.movie.rating.toString()),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )
            )
          ],
        ),
      ),
    );
  }
}

class WatchList extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Watch List"),),
        body: Consumer<WatchListModel>(
          builder: (context, watchList, child){
            return ListView.builder(
              itemCount: watchList.numItems,
              itemBuilder: (BuildContext context, int index){
                return Container(

                    margin: EdgeInsets.all(7.0),
                    height: 40,
                    color: Colors.blue,
                    child: Center(child: Text(style: TextStyle(fontSize: 25.0,),watchList.getItem(index).title)));
              },
            );
          },
        )
    );
  }
}

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


class WatchListModel extends ChangeNotifier{

  final List<Movie> _watchList = [];

  int get numItems => _watchList.length;
  Movie getItem(int index) => _watchList[index];

  bool itemExists(Movie movie) => _watchList.indexOf(movie)>=0 ? true: false;

  void add(Movie movie){
    _watchList.add(movie);
    notifyListeners();
  }

  void remove(Movie movie){
    _watchList.remove(movie);
    notifyListeners();
  }

  void removeAll(){
    _watchList.clear();
    notifyListeners();
  }
}




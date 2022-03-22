import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movies/main.dart';
class Details extends StatelessWidget {
  late final Movie movie;
  Details(this.movie);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.blue[100] ,
      appBar:  AppBar(
        title: Text("Details"),
      ),
      body: Center(
        child: Container(


          margin: EdgeInsets.all(10.0),
          width: 250,
          height: 500,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(33),
                child: Image.network(
                  this.movie.image,

                ),
              ),

              Text( movie.title,style: TextStyle(fontSize: 25.0,),textAlign: TextAlign.center,),

              Text( movie.year,style: TextStyle(fontSize: 25.0),),
              Text("Rating: ${movie.rating.toString()}",style: TextStyle(fontSize: 25.0),),

              Text(movie.genre.toString(),style: TextStyle(fontSize: 20.0),),


              SizedBox(height: 20,)

            ],
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(33.0),
            color: Colors.blue[500],
            boxShadow: [
              BoxShadow(color: Colors.black45, spreadRadius: 3),
            ],
          ),
        ),
      ),
    );
  }
}

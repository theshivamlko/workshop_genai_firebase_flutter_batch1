import 'package:flutter/material.dart';

class SearchResponse {
  String textResponse;
  List<WebLink>? links;

  SearchResponse(this.textResponse, {this.links });

}

class WebLink{
  String pageTitle;
  String url;
  WebLink(this.pageTitle,this.url);
}
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drivers_app/global/global_var.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:drivers_app/models/direction_details.dart';
import 'package:http/http.dart' as http;

class CommonMethods
{
  checkConnectivity(BuildContext context) async {
    var connectionResult = await Connectivity().checkConnectivity();
    if(connectionResult!=ConnectivityResult.mobile && connectionResult!=ConnectivityResult.wifi)
      {
        if(!context.mounted) return;
        displaySnackBar("Your Internet is not Available. Check your connection and try again!", context);
      }
  }

  displaySnackBar(String messageText, BuildContext context)
  {
    var snackBar = SnackBar(content: Text(messageText));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  turnOffLocationUpdatesForHomepage( ) {
    positionStreamHomePage!.pause();
    //remove current driver who accepted new trip request from parent node "onlineDrivers"
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);
  }

  turnOnLocationUpdatesForHomepage( ) {
    positionStreamHomePage!.resume();
    Geofire.setLocation(
      FirebaseAuth.instance.currentUser!.uid,
      driverCurrentPosition!.latitude,
      driverCurrentPosition!.longitude,
    );
  }

  static sendRequestToAPI (String apiUrl) async {
    http.Response responseFromAPI = await http.get(Uri.parse(apiUrl));
    try {
      if(responseFromAPI.statusCode == 200) {
        String dataFromApi = responseFromAPI.body;
        var dataDecoded = jsonDecode(dataFromApi);
        return dataDecoded;
      }
      else {
        return "error";
      }
    } catch (errorMsg) {
      return "error";
    }
  }

  //Directions API
  static Future<DirectionDetails?> getDirectionDetailsFromAPI(LatLng source, LatLng destination) async {
    String urlDirectionsAPI = "https://maps.googleapis.com/maps/api/directions/json?destination=${destination.latitude},${destination.longitude}&origin=${source.latitude},${source.longitude}&mode=driving&key=$googleMapKey";
    var responseFromDirectionsAPI = await sendRequestToAPI(urlDirectionsAPI);
    if(responseFromDirectionsAPI == "error") {
      return null;
    }
    DirectionDetails detailsModel = DirectionDetails();
    detailsModel.distanceTextString = responseFromDirectionsAPI["routes"][0]["legs"][0]["distance"]["text"];
    detailsModel.distanceValueDigits = responseFromDirectionsAPI["routes"][0]["legs"][0]["distance"]["value"];
    detailsModel.durationTextString = responseFromDirectionsAPI["routes"][0]["legs"][0]["duration"]["text"];
    detailsModel.durationValueDigits = responseFromDirectionsAPI["routes"][0]["legs"][0]["duration"]["value"];
    detailsModel.encodedPoints = responseFromDirectionsAPI["routes"][0]["overview_polyline"]["points"];

    return detailsModel;

  }

  calculateFareAmount(DirectionDetails directionDetails) {
    double distancePerKmAmount = 10000;
    double durationPerMinuteAmount = 9000;
    double baseFareAmount = 7000;

    double totalDistanceTravelFareAmount = (directionDetails.distanceValueDigits! /1000) * distancePerKmAmount;
    double totalDurationSpendFareAmount = (directionDetails.durationValueDigits! / 60) * durationPerMinuteAmount;

    double overAllTotalFareAmount = baseFareAmount + totalDurationSpendFareAmount + totalDistanceTravelFareAmount;
    return overAllTotalFareAmount.toStringAsFixed(1);
  }
}

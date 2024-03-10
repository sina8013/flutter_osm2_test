import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false,
      ),
      home: const MyWidget(),
    );
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

MapController mapController = MapController();
List<Marker> markersList = [];

Position? lastPosition;

class _MyWidgetState extends State<MyWidget> {
  @override
  void initState() {
    super.initState();
    initer();
  }

  initer({bool bypass = false}) {
    getLocationPermition().then((state) {
      if (state) {
        if (bypass == false) {
          getLastPosition().then((state2) {
            setState(() {
              lastPosition = state2;
              mapController.move(
                  LatLng(state2!.latitude, state2.longitude), 16);
            });
          });
        }

        getCurrentPosition().then((state3) {
          lastPosition = state3;
          mapController.move(LatLng(state3.latitude, state3.longitude), 16);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 50,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                initer(bypass: true);
              },
              child: Icon(Icons.my_location),
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  )),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            width: 150,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                print(mapController.camera.center.latitude);
                print(mapController.camera.center.longitude);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("  ذخیره موقعیت "),
                  Icon(Icons.add_location_rounded),
                ],
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              minZoom: 6,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.doubleTapDragZoom |
                    InteractiveFlag.pinchZoom |
                    InteractiveFlag.pinchMove |
                    InteractiveFlag.drag |
                    InteractiveFlag.flingAnimation,
              ),
              initialCenter: const LatLng(35.739095, 51.298555),
              initialZoom: 15,
              onPointerDown: (event, point) {
                print("object");
              },
              onPointerUp: (event, point) {
                print("object2");
              },
              onPositionChanged: (position, hasGesture) {
                // print(position.center!.latitude);
                // print(position.center!.longitude);
                print(hasGesture);
                // setState(() {
                //   markersList = [
                //     Marker(
                //       point: LatLng(
                //           position.center!.latitude, position.center!.longitude),
                //       width: 70,
                //       height: 70,
                //       child: Icon(
                //         Icons.place,
                //         color: Colors.red,
                //         size: 50,
                //       ),
                //     )
                //   ];
                // });
              },
              onTap: (tapPosition, point) {
                // setState(() {
                //   markersList = [
                //     Marker(
                //       point: LatLng(point.latitude, point.longitude),
                //       width: 70,
                //       height: 70,
                //       child: const FlutterLogo(),
                //     )
                //   ];
                // });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                // urlTemplate:
                //     'https://api.mapbox.com/styles/v1/sina8013/cltj1lskc008s01pj68ffbugk/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1Ijoic2luYTgwMTMiLCJhIjoiY2xsajZ2eHdmMGZjcDNjbnFldzg2bDY1cyJ9.uEWDPmYZS6ZXxq33ymDeTA',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(markers: markersList),
            ],
          ),
          Center(
            child: Container(
              height: 100,
              // color: const Color.fromARGB(49, 33, 149, 243),
              child: const Column(
                children: [
                  Icon(
                    Icons.place,
                    color: Colors.red,
                    size: 50,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> getLocationPermition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // return Future.error('Location services are disabled.');
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
        // return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // return Future.error(
      //     'Location permissions are permanently denied, we cannot request permissions.');
      return false;
    }

    return true;
  }

  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition();
  }

  Future<Position?> getLastPosition() async {
    return await Geolocator.getLastKnownPosition();
  }
}

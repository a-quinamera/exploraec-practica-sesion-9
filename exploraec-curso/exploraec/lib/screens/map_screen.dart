import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/places_controller.dart';
import '../models/place.dart';
import '../theme/app_theme.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import 'detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final controller = Get.find<PlacesController>();
  final mapController = MapController();

  @override
  void initState() {
    super.initState();
    controller.cargarPosicion();
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  void _abrirLugar(Place lugar) {
    Get.to(() => DetailScreen(
        place: lugar, distanciaMetros: controller.distanciaA(lugar)));
  }

  void _verLugares() {
    if (controller.lugares.isEmpty) return;
    mapController.fitCamera(CameraFit.bounds(
      bounds: LatLngBounds.fromPoints(controller.lugares
          .map((lugar) => LatLng(lugar.lat, lugar.lng))
          .toList()),
      padding: const EdgeInsets.all(70),
      maxZoom: 15,
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Mapa'), actions: [
          Obx(() => PopupMenuButton<Place>(
                tooltip: 'Lugares en el mapa',
                icon: Badge(
                    label: Text(controller.total.toString()),
                    child: const Icon(Icons.list)),
                itemBuilder: (_) => controller.lugares
                    .map((lugar) =>
                        PopupMenuItem(value: lugar, child: Text(lugar.nombre)))
                    .toList(),
                onSelected: _abrirLugar,
              )),
        ]),
        body: Obx(() {
          if (controller.estadoPosicion.value == EstadoCarga.cargando) {
            return const LoadingView(mensaje: 'Obteniendo tu ubicación...');
          }
          if (controller.estadoPosicion.value == EstadoCarga.error) {
            return ErrorView(
                mensaje: controller.mensajeErrorPosicion.value,
                onReintentar: () => controller.cargarPosicion(forzar: true));
          }
          return _buildMapa(
              controller.posicion.value!, controller.lugares.toList());
        }),
        floatingActionButton: Obx(() {
          if (controller.estadoPosicion.value != EstadoCarga.exito) {
            return const SizedBox.shrink();
          }
          return Column(mainAxisSize: MainAxisSize.min, children: [
            FloatingActionButton.small(
                heroTag: 'ver-lugares',
                tooltip: 'Ver todos los lugares',
                onPressed: _verLugares,
                child: const Icon(Icons.place)),
            const SizedBox(height: 12),
            FloatingActionButton(
                heroTag: 'mi-ubicacion',
                tooltip: 'Centrar en mi ubicación',
                onPressed: () {
                  final pos = controller.posicion.value;
                  if (pos != null) {
                    mapController.move(LatLng(pos.latitude, pos.longitude), 15);
                  }
                },
                child: const Icon(Icons.my_location)),
          ]);
        }),
      );

  Widget _buildMapa(Position posicion, List<Place> lugares) {
    final miUbicacion = LatLng(posicion.latitude, posicion.longitude);
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(initialCenter: miUbicacion, initialZoom: 15),
      children: [
        TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.tmo.exploraec'),
        MarkerLayer(markers: [
          Marker(
              point: miUbicacion,
              width: 40,
              height: 40,
              child: const Tooltip(
                  message: 'Mi ubicación actual',
                  child:
                      Icon(Icons.my_location, color: Colors.blue, size: 32))),
          ...lugares.map((lugar) => Marker(
                point: LatLng(lugar.lat, lugar.lng),
                width: 48,
                height: 48,
                child: IconButton(
                    tooltip: 'Ver ${lugar.nombre}',
                    onPressed: () => _abrirLugar(lugar),
                    icon: Icon(Icons.place,
                        color: AppTheme.colorPrimario, size: 36)),
              )),
        ]),
        Align(
            alignment: Alignment.topLeft,
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12)),
              child:
                  Text('${lugares.length} lugares · Ubicación actual obtenida'),
            )),
        const Align(
          alignment: Alignment.bottomLeft,
          child: ColoredBox(
              color: Colors.white,
              child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Text('© OpenStreetMap contributors',
                      style: TextStyle(color: Colors.black, fontSize: 12)))),
        ),
      ],
    );
  }
}

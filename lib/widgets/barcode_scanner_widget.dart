
// import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
// import 'package:flutter/material.dart';


// // import 'barcode_widget_page.dart';

// class Scanner extends StatelessWidget {
//   const new({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Scan Code',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const ScanCode(),
//     );
//   }
// }

// class ScanCode extends StatefulWidget {
//   const ScanCode({Key? key}) : super(key: key);

//   @override
//   State<ScanCode> createState() => _ScanCodeState();
// }

// class _ScanCodeState extends State<ScanCode> {
//   String result = '';
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ElevatedButton(
//               onPressed: () async {
//                 String? res = await SimpleBarcodeScanner.scanBarcode(
//                   context,
//                   barcodeAppBar: const BarcodeAppBar(
//                     appBarTitle: 'Test',
//                     centerTitle: false,
//                     enableBackButton: true,
//                     backButtonIcon: Icon(Icons.arrow_back_ios),
//                   ),
//                   isShowFlashIcon: true,
//                   delayMillis: 500,
//                   cameraFace: CameraFace.back,
//                   scanFormat: ScanFormat.ONLY_BARCODE,
//                 );
//                 setState(() {
//                   result = res as String;
//                 });
//               },
//               child: const Text('Scan Barcode'),
              
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             Text('Scan Barcode Result: $result'),
//             const SizedBox(
//               height: 10,
//             ),
//             // ElevatedButton(
//             //   onPressed: () async {
//             //     SimpleBarcodeScanner.streamBarcode(
//             //       context,
//             //       barcodeAppBar: const BarcodeAppBar(
//             //         appBarTitle: 'Test',
//             //         centerTitle: false,
//             //         enableBackButton: true,
//             //         backButtonIcon: Icon(Icons.arrow_back_ios),
//             //       ),
//             //       isShowFlashIcon: true,
//             //       delayMillis: 2000,
//             //     ).listen((event) {
//             //       print("Stream Barcode Result: $event");
//             //     });
//             //   },
//             //   child: const Text('Stream Barcode'),
//             // ),

            
//             const SizedBox(
//               height: 10,
//             ),
//             // ElevatedButton(
//             //     onPressed: () {
//             //       Navigator.push(context, MaterialPageRoute(builder: (context) {
//             //         // return const BarcodeWidgetPage();
//             //       }
//             //       ));
//             //     },
//             //     child: const Text('Barcode Scanner Widget(Android Only)'))
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:pos_app/providers/menu_provider.dart';
// import 'package:provider/provider.dart';

// // This widget is a barcode scanner that uses the device's camera to detect barcodes. 
// // It provides a simple interface for scanning and returns the detected barcode to the parent widget through a callback function.
// class BarcodeScannerWidget extends StatefulWidget {
  
//   // Callback function to handle the detected barcode. This function is called when a barcode is successfully scanned.
//   final Function(String barcode) onBarcodeDetected;

//   const BarcodeScannerWidget({
//     super.key,
//     // The callback function is required to ensure that the parent widget can handle the scanned barcode.
//     required this.onBarcodeDetected,
//   });

//   @override
//   State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
// }

// class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
//   // MobileScannerController is used to control the camera and scanning behavior.
//   late final MobileScannerController controller;
//   // _isProcessing is a flag to prevent multiple detections of the same barcode in quick succession.
//   bool _isProcessing = false;
//   // _status is a string that holds the current status message displayed to the user.
//   String _status = 'Point camera at barcode...';

//   @override
//   void initState() {
//     //Run this code whenever someone comes to this screen
//     super.initState();

//     // Initialize the MobileScannerController with specific settings for barcode detection.
//     controller = MobileScannerController(
//       detectionSpeed: DetectionSpeed.noDuplicates, // important
//       facing: CameraFacing.back,
//       torchEnabled: false,
//       formats: [BarcodeFormat.all], // uncomment if needed
//     );

//     // Start the scanner
//     controller.start();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Scan Barcode'),
//         actions: [
//           // // Torch toggle button
//           // IconButton(
//           //     //
//           //   icon: ValueListenableBuilder(
//           //     valueListenable: controller,
//           //     builder: (context, state, child) {
//           //       final isOn = state.torchState == TorchState.on;
//           //       return Icon(
//           //         isOn ? Icons.flash_on : Icons.flash_off,
//           //         color: isOn ? Colors.yellow : null,
//           //       );
//           //     },
//           //   ),
//           //   onPressed: () => controller.toggleTorch(),
//           // ),
//           IconButton(
//                   icon: const Icon(Icons.qr_code_scanner),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => BarcodeScannerWidget(
//                           onBarcodeDetected: (String barcode) {
//                             // This runs after a successful scan
//                             print('Scanned barcode: $barcode');

//                             final menuProvider = context.read<MenuProvider>();
//                             final item = menuProvider.findByBarcode(barcode);

//                             if (item == null) {
//                               // Show create new item dialog
//                               _showCreateNewItemDialog(barcode);
                              
//                             } else {
//                               // Show add stock / add to order
//                               _showAddStockByBarcode(barcode);
//                             }
//                           },
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//           IconButton(
//             icon: const Icon(Icons.cameraswitch),
//             onPressed: () => controller.switchCamera(),
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           MobileScanner(
//             controller: controller,
//             onDetect: (BarcodeCapture capture) {
//                           if (_isProcessing) return;

//                           final barcodes = capture.barcodes;
//                           if (barcodes.isEmpty) return;

//                           final String? code = barcodes.first.rawValue;
//                           if (code == null || code.isEmpty) return;

//                           // Prevent multiple scans
//                           _isProcessing = true;

//                           // Update UI
//                           setState(() {
//                             _status = 'Detected: $code';
//                           });

//                           // Stop the camera first (recommended)
//                           controller.stop().then((_) {
//                             // Send the barcode back
//                             widget.onBarcodeDetected(code);

//                             // Close the scanner screen
//                             if (mounted) {
//                               Navigator.pop(context);
//                             }
//                           });
//                         },
//           ),

//           // Green frame
//           Center(
//             child: Container(
//               width: 260,
//               height: 260,
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.greenAccent, width: 3),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//           ),

//           // Status text at the bottom
//           Positioned(
//             bottom: 40,
//             left: 20,
//             right: 20,
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//               decoration: BoxDecoration(
//                 color: Colors.black87,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 _status,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:pos_app/providers/menu_provider.dart';
// import 'package:provider/provider.dart';

// class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
//   late final MobileScannerController controller;
//   bool _isProcessing = false;
//   String _status = 'Point camera at barcode...';

//   @override
//   void initState() {
//     super.initState();
//     controller = MobileScannerController(
//       detectionSpeed: DetectionSpeed.noDuplicates,
//       facing: CameraFacing.back,
//       torchEnabled: false,
//       formats: [BarcodeFormat.all],
//     );
//     controller.start();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Scan Barcode'),
//         actions: [
//           // Optional: Torch toggle button
//           IconButton(
//             icon: ValueListenableBuilder(
//               valueListenable: controller,
//               builder: (context, state, child) {
//                 final isOn = state.torchState == TorchState.on;
//                 return Icon(
//                   isOn ? Icons.flash_on : Icons.flash_off,
//                   color: isOn ? Colors.yellow : null,
//                 );
//               },
//             ),
//             onPressed: () => controller.toggleTorch(),
//           ),
//           // Camera switch button
//           IconButton(
//             icon: const Icon(Icons.cameraswitch),
//             onPressed: () => controller.switchCamera(),
//           ),
//         ],
//       ),
//       body: Stack(
//         // ... body implementation remains the same
//         children: [
//           MobileScanner(
//             controller: controller,
//             onDetect: (BarcodeCapture capture) {
//               if (_isProcessing) return;

//               final barcodes = capture.barcodes;
//               if (barcodes.isEmpty) return;

//               final String? code = barcodes.first.rawValue;
//               if (code == null || code.isEmpty) return;

//               _isProcessing = true;

//               setState(() {
//                 _status = 'Detected: $code';
//               });

//               controller.stop().then((_) {
//                 widget.onBarcodeDetected(code);
//                 if (mounted) {
//                   Navigator.pop(context);
//                 }
//               });
//             },
//           ),
//           Center(
//             child: Container(
//               width: 260,
//               height: 260,
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.greenAccent, width: 3),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 40,
//             left: 20,
//             right: 20,
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//               decoration: BoxDecoration(
//                 color: Colors.black87,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 _status,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
// }


import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerWidget extends StatefulWidget {
  // Callback function to handle the detected barcode.
  final Function(String barcode) onBarcodeDetected;

  const BarcodeScannerWidget({
    super.key,
    required this.onBarcodeDetected,
  });

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  // Controller to manage camera and scanning behavior
  late final MobileScannerController controller;
  
  // Flag to prevent multiple rapid scans of the same barcode
  bool _isProcessing = false;
  
  // Status message displayed at the bottom of the screen
  String _status = 'Point camera at barcode...';

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
      formats: [BarcodeFormat.all],
    );
    controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        actions: [
          // Torch toggle button
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, state, child) {
                final isOn = state.torchState == TorchState.on;
                return Icon(
                  isOn ? Icons.flash_on : Icons.flash_off,
                  color: isOn ? Colors.yellow : null,
                );
              },
            ),
            onPressed: () => controller.toggleTorch(),
          ),
          // Camera switch button (front/back)
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera Scanner View
          MobileScanner(
            controller: controller,
            onDetect: (BarcodeCapture capture) {
              if (_isProcessing) return;

              final barcodes = capture.barcodes;
              if (barcodes.isEmpty) return;

              final String? code = barcodes.first.rawValue;
              if (code == null || code.isEmpty) return;

              // Prevent multiple scans
              _isProcessing = true;

              // 1. Close the scanner screen FIRST so it disappears instantly
              if (mounted) {
                Navigator.pop(context);
              }

              // 2. Then pass the barcode back to your InventoryScreen
              widget.onBarcodeDetected(code);
            },
          ),

          // Visual guide frame (Green box)
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.greenAccent, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Status text banner at the bottom
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
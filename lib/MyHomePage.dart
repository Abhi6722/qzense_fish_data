import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, required this.accessToken})
      : super(key: key);

  final String title;
  final String accessToken;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  XFile? _image;
  late String _fishType = 'Tuna';
  late final String _otherFishType = '';
  late String _label = '';

  String dropdownValue = 'Tuna';
  var fishes = [
    'Tuna',
    'Seer',
    'Mackerel',
    'Sardine',
    'Indian Salmon',
    'Pink Perch',
    'Croaker',
    'Mullet',
    'Black Pomfret',
    'White Pomfret',
    'Tilapia',
    'Rohu',
    'Roopchand',
    'White Prawns',
    'Blue Crab',
    'Tiger Prawns',
    'Other'
  ];

  late bool _showOtherFishTypeField = false;
  final _descriptionController = TextEditingController();
  final picker = ImagePicker();
  // final TextEditingController _otherFishTypeController = TextEditingController();

  final TextEditingController _otherFishTypeController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _validateFishType(String? value) {
    if (_fishType == 'Other' &&
        (_otherFishTypeController.text == '' || _otherFishType == '')) {
      return 'Please enter the fish type';
    }
    return null;
  }

  void setFishType(String type) {
    setState(() {
      _fishType = type;
      if (_fishType != 'Other') {
        _showOtherFishTypeField = false;
      }
    });
  }

  void setFishLabel(String label) {
    setState(() {
      _label = label;
    });
  }

  void _resetForm() {
    setState(() {
      _image = null;
      _label = '';
      _descriptionController.clear();
      _otherFishTypeController.clear();
    });
  }

  Future pickImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = XFile(pickedFile.path);
      } else {
        // print('No image selected.');
      }
    });
  }

  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = XFile(pickedFile.path);
      } else {
        // print('No image selected.');
      }
    });
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future sendDataToBackend() async {
    // Validate required fields
    if (_image == null || _fishType.isEmpty || _label.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Please fill in all required fields.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    if (_fishType == 'Other' && _otherFishTypeController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Please enter the Other fish type.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    final uri = Uri.parse('http://15.207.142.254:8000/api/fish/');
    final request = http.MultipartRequest('POST', uri);

    if (_image != null) {
      final file = await http.MultipartFile.fromPath('ImageFile', _image!.path);
      request.files.add(file);
    }

    request.headers['Authorization'] = 'Bearer ${widget.accessToken}';
    request.fields['type'] =
        _fishType == 'Other' ? _otherFishTypeController.text : _fishType;
    request.fields['labels'] = _label;
    request.fields['description'] = _descriptionController.text;

    // // Print data being sent to API
    // print('Sending data to API: ${request.fields.toString()}');

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        showSuccessDialog(
            'Data sent successfully,\nThe data Sent is: ${request.fields.toString()}');
        _resetForm();
      } else {
        showErrorDialog('Failed to send data. Please log in again!');
      }
    } catch (e) {
      showErrorDialog('Error sending data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF27485D),
        title: const Center(child: Text('Fish Data Collection')),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_image != null) ...[
                  // const SizedBox(height: 10.0),
                  Image.file(
                    File(_image!.path),
                    width: 150.0,
                    height: 200.0,
                    fit: BoxFit.cover,
                  ),
                ],

                const SizedBox(height: 15.0),

                Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    direction: Axis.horizontal,
                    spacing: 10,
                    runSpacing: 5,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        child: MaterialButton(
                          height: 50,
                          color: const Color(0xFF27485D),
                          onPressed: pickImageFromCamera,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Take Photo',
                                  style: TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: MaterialButton(
                          height: 50,
                          color: const Color(0xFF27485D),
                          onPressed: pickImage,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.photo_library, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Upload Image',
                                  style: TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20.0),
                Text('Label:', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 5.0),
                // Labels Good, Bad, Ok
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: buildLabelContainer(
                            label: 'good',
                            color: Colors.green,
                            labelText: 'Good',
                          ),
                        ),
                        Expanded(
                          child: buildLabelContainer(
                            label: 'bad',
                            color: Colors.red,
                            labelText: 'Bad',
                          ),
                        ),
                        Expanded(
                          child: buildLabelContainer(
                            label: 'ok',
                            color: Colors.orange,
                            labelText: 'OK',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20.0),
                Text('Description (Optional)',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 5.0),
                TextField(
                  decoration: const InputDecoration(
                      hintText: 'Description',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFF27485D), width: 1.0),
                      )),
                  controller: _descriptionController,
                  maxLines: 2,
                ),

                const SizedBox(height: 20.0),
                Text('Fish Type:',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 5.0),

                // Checkbox
                Form(
                  key: _formKey,
                  child: Wrap(
                    direction: Axis.horizontal,
                    spacing: 10,
                    runSpacing: 5,
                    children: [
                      SizedBox(
                        child: buildFishTypeContainer(
                          fishType: 'tuna',
                          labelText: 'Tuna',
                        ),
                      ),
                      SizedBox(
                        child: buildFishTypeContainer(
                          fishType: 'seer',
                          labelText: 'Seer',
                        ),
                      ),
                      SizedBox(
                        child: buildFishTypeContainer(
                          fishType: 'mackerel',
                          labelText: 'Mackerel',
                        ),
                      ),
                      SizedBox(
                        child: buildFishTypeContainer(
                          fishType: 'sardine',
                          labelText: 'Sardine',
                        ),
                      ),
                      SizedBox(
                        child: buildFishTypeContainer(
                          fishType: 'pink perch',
                          labelText: 'Pink Perch',
                        ),
                      ),
                      SizedBox(
                        child: buildFishTypeContainer(
                          fishType: 'croaker',
                          labelText: 'Croaker',
                        ),
                      ),
                      SizedBox(
                        child: buildFishTypeContainer(
                          fishType: 'mullet',
                          labelText: 'Mullet',
                        ),
                      ),
                      SizedBox(
                        child: buildFishTypeContainer(
                          fishType: 'tilapia',
                          labelText: 'Tilapia',
                        ),
                      ),
                      SizedBox(
                        child: buildFishTypeContainer(
                          fishType: 'rohu',
                          labelText: 'Rohu',
                        ),
                      ),
                      SizedBox(
                        child: buildFishTypeContainer(
                          fishType: 'roopchand',
                          labelText: 'Roopchand',
                        ),
                      ),
                      SizedBox(
                        child: buildFishTypeContainer(
                          fishType: 'Indian salmon',
                          labelText: 'Indian Salmon',
                        ),
                      ),
                      SizedBox(
                        child: buildFishTypeContainer(
                          fishType: 'white pomfret',
                          labelText: 'White Pomfret',
                        ),
                      ),
                      SizedBox(
                        child: buildFishTypeContainer(
                          fishType: 'black pomfret',
                          labelText: 'Black Pomfret',
                        ),
                      ),
                      SizedBox(
                        child: buildFishTypeContainer(
                          fishType: 'white prawns',
                          labelText: 'White Prawns',
                        ),
                      ),
                      SizedBox(
                        child: buildFishTypeContainer(
                          fishType: 'blue crab',
                          labelText: 'Blue Crab',
                        ),
                      ),
                      SizedBox(
                        child: buildFishTypeContainer(
                          fishType: 'tiger prawns',
                          labelText: 'Tiger Prawns',
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            child: Container(
                              width: 120,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 0),
                              color: _fishType == 'Other'
                                  ? Colors.cyan.withOpacity(0.1)
                                  : null,
                              child: Row(
                                children: [
                                  const Text(
                                    'Other',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  Checkbox(
                                    value: _fishType == 'Other',
                                    onChanged: (value) {
                                      if (value!) {
                                        setState(() {
                                          _fishType = 'Other';
                                          _showOtherFishTypeField = true;
                                        });
                                      } else {
                                        setState(() {
                                          _fishType = 'tuna';
                                          _showOtherFishTypeField = false;
                                        });
                                      }
                                    },
                                    shape: const CircleBorder(),
                                    activeColor: const Color(0xFF27485D),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_showOtherFishTypeField) ...[
                        const SizedBox(height: 10.0),
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Enter Fish Type',
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xFF27485D), width: 1.0),
                            ),
                          ),
                          controller: _otherFishTypeController,
                          validator:
                              _validateFishType, // Add the validator here
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 10.0),
                MaterialButton(
                  onPressed: sendDataToBackend,
                  color: const Color(0xFF27485D),
                  child: const Text('Submit',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFishTypeContainer({
    required String fishType,
    required String labelText,
  }) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(2),
      color: _fishType == fishType ? Colors.cyan.withOpacity(0.1) : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            labelText,
            style: const TextStyle(fontSize: 14),
          ),
          Checkbox(
            value: _fishType == fishType,
            onChanged: (value) => setFishType(value! ? fishType : ''),
            shape: const CircleBorder(),
            activeColor: const Color(0xFF27485D),
          ),
        ],
      ),
    );
  }

  Widget buildLabelContainer({
    required String label,
    required Color color,
    required String labelText,
  }) {
    return Container(
      padding: const EdgeInsets.all(1),
      color: _label == label ? color.withOpacity(0.2) : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: TextStyle(color: color),
          ),
          Checkbox(
            value: _label == label,
            onChanged: (value) => setFishLabel(value! ? label : ''),
            shape: const CircleBorder(),
            activeColor: color,
          ),
        ],
      ),
    );
  }
}

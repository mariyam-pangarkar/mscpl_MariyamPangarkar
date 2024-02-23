import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

TextEditingController _otpcontroller = TextEditingController();
Color buttonColor = Colors.black;
bool backmobilechange = true;
int _backCount = 0;

void main() {
  runApp(MaterialApp(
    home: MobileNumberScreen(),
  ));
}

class MobileNumberScreen extends StatefulWidget {
  @override
  _MobileNumberScreenState createState() => _MobileNumberScreenState();
}

class _MobileNumberScreenState extends State<MobileNumberScreen> {
  final TextEditingController _mobileController = TextEditingController();
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {},
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Text(
                  'Enter your Mobile no',
                  style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF101828)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'We need to verify your number',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF667085)),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mobile Number',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF101828),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: TextField(
                      keyboardType:TextInputType.number,
                        
                        controller: _mobileController,
                        decoration: InputDecoration(
                          labelText: 'Enter mobile no',
                          labelStyle: TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _isChecked = false;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 100.0),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                                  (states) {
                            if (states.contains(MaterialState.disabled)) {
                              return Colors.grey;
                            }
                            return buttonColor;
                          }),
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        onPressed:
                            _isChecked && _mobileController.text.length == 10
                                ? () {
                                    String maskedNumber = _mobileController.text
                                        .replaceRange(0, 6, '******');
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            OtpScreen(maskedNumber),
                                      ),
                                    );
                                   
                                  }
                                : null,
                        child: Text('Get OTP'),
                      ),
                    ),
                    SizedBox(height: 16.0),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Checkbox(
                            value: _isChecked,
                            onChanged: (value) {
                              setState(() {
                                _isChecked = value!;
                              });
                            },
                          ),
                          Flexible(
                              child: Text(
                                  'Allow fydaa to send financial knowledge and critical alerts on your WhatsApp')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OtpScreen extends StatefulWidget {
  final String maskedNumber;

  OtpScreen(this.maskedNumber);

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  int _resendCount = 0;
  bool _isResendDisabled = true;
  int _timerCount = 170;
  late Timer _timer;
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  int _otpLength = 6;
  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(_otpLength, (index) => FocusNode());
    _controllers =
        List.generate(_otpLength, (index) => TextEditingController());
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timerCount > 0) {
          _timerCount--;
        } else {
          _isResendDisabled = false;
          _timer.cancel();
        }
      });
    });
  }

  void resendOtp() {
    if (_resendCount < 5) {
      _resendCount++;
      _timerCount = 170;
      _isResendDisabled = true;
      startTimer();
    }
  }

  bool checkOtp = false;
  int otplength = 0;

  void _otpChanged(String value, int index) {
    if (value.length == 0) {
      setState(() {
        otplength = 0;
      });
    }
    if (value.length == 1 && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty) {
      _focusNodes[index].unfocus();
      if (index > 0) {
        FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      }
    } else {
      _focusNodes[index].requestFocus();
      if (index < _otpLength - 1) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      }
    }
    
    if (index == _otpLength - 1 && value.length == 1) {
      String otp = _controllers.fold<String>(
          "", (previousValue, controller) => previousValue + controller.text);
       if (otp == "934477") {
          setState(() {
             checkOtp = true;
          otplength = 1;
          });
        
         
        } else {
            setState(() {
          checkOtp = false;
          otplength = 2;
             });
        }
    }

    print("OTP: $value");
  }

  void _pasteOTP(String otp) {
    for (int i = 0; i < otp.length && i < _otpLength; i++) {
      _controllers[i].text = otp[i];
      if (i < _otpLength - 1) {
        _focusNodes[i + 1].requestFocus();
      }
      if (i == _otpLength - 1) {
        print('otp');
        print(otp);
        if (otp == "934477") {
          setState(() {
             checkOtp = true;
          otplength = 1;
          });
        
         
        } else {
            setState(() {
          checkOtp = false;
          otplength = 2;
             });
        }
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:true,
      appBar: AppBar(
        title: Text('Verify your phone'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
              Navigator.pop(context, widget.maskedNumber);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Text(
                  'Verify your phone',
                  style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF101828)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: Text(
                  'Enter the verification code sent to ${widget.maskedNumber}',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF101828),
                  ),
                ),
              ),
              
              SizedBox(height: 20.0),
              Container(
                decoration: BoxDecoration(
                    color: otplength == 1 && checkOtp
                        ? Colors.green
                        : otplength == 2 && checkOtp == false
                            ? Colors.red
                            : Colors.white,
                    border: Border.all(
                      color: otplength == 1 && checkOtp
                          ? Colors.green
                          : otplength == 2 && checkOtp == false
                              ? Colors.red
                              : Colors.white,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            _otpLength,
                            (index) {
                              return GestureDetector(
                                child: Container(
                                  width: 40.0,
                                  height: 40.0,
                                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: otplength != 0
                                          ? Colors.white
                                          : Colors.black,
                                      width: 1.0,
                                    ),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: TextField(
                                    controller: _controllers[index],
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    autofocus: index == 0 ? true : false,
                                    focusNode: _focusNodes[index],
                                    maxLength: index == 0 ? 6 : 1,
                                    onChanged: (value) {
                                      if (value.length > 1) {
                                        _pasteOTP(
                                            value); 
                                      } else {
                                        _otpChanged(value, index);
                                      }
                                    },
                                    decoration: InputDecoration(
                                      counterText: '',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              otplength == 1 && checkOtp
                                  ? Icons.check
                                  : otplength == 2 && checkOtp == false
                                      ? Icons.close
                                      : null,
                              color: Colors.white,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                otplength == 1 && checkOtp
                                    ? 'Verified'
                                    : otplength == 2 && checkOtp == false
                                        ? 'Invalid OTP'
                                        : '',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18.0, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(width: 16.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Resend in $_timerCount sec'),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            // backgroundColor:Colors.white,
                            foregroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                                    (states) {
                              if (states.contains(MaterialState.disabled)) {
                                return Colors.grey;
                              }
                              return Colors.black;
                            }),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          onPressed: _isResendDisabled ? null : resendOtp,
                          child: Text('Resend Code'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(
                                      Colors.white),
                              foregroundColor:
                                  MaterialStateProperty.all<Color>(
                                      Colors.black),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.black),
                                ),
                              ),
                            ),
                            onPressed: () {
                              
              
                                Navigator.pop(context, widget.maskedNumber);
                              
                            },
                            child: Text('Change Number'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
             
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter_svg/flutter_svg.dart';
import 'package:fusecash/redux/actions/user_actions.dart';
import 'package:fusecash/screens/misc/pincode.dart';
import 'package:fusecash/screens/routes.gr.dart';
import 'package:fusecash/utils/biometric_local_auth.dart';
import 'package:redux/redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fusecash/generated/i18n.dart';
import 'package:fusecash/models/app_state.dart';
import 'package:fusecash/widgets/main_scaffold.dart';

class ProtectYourWallet extends StatefulWidget {
  @override
  _ProtectYourWalletState createState() => _ProtectYourWalletState();
}

class _ProtectYourWalletState extends State<ProtectYourWallet> {
  BiometricAuth _biometricType;

  Future<void> _checkBiometricable() async {
    _biometricType = await BiometricUtils.getAvailableBiometrics();
    if (_biometricType != BiometricAuth.none) {
      setState(() {
        _biometricType = _biometricType;
      });
    }
  }

  @override
  void initState() {
    _checkBiometricable();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: I18n.of(context).protect_wallet,
      withPadding: true,
      children: <Widget>[
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              StoreConnector<AppState, _SecurityViewModel>(
                  distinct: true,
                  converter: _SecurityViewModel.fromStore,
                  builder: (_, viewModel) {
                    final isBiometric =
                        viewModel.authType == BiometricAuth.faceID ||
                            viewModel.authType == BiometricAuth.touchID;
                    return Container(
                      child: ListView(
                        shrinkWrap: true,
                        primary: false,
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        children: <Widget>[
                          InkWell(
                            child: Container(
                                height: 60,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                width: MediaQuery.of(context).size.width * .8,
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: const Color(0xFFDCDCDC)))),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        SvgPicture.asset(
                                            'assets/images/${BiometricAuth.faceID == _biometricType ? 'face_id' : 'fingerprint'}.svg'),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          BiometricUtils.getBiometricString(
                                              _biometricType),
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black),
                                        )
                                      ],
                                    ),
                                    isBiometric
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              SvgPicture.asset(
                                                'assets/images/checkmark.svg',
                                              ),
                                            ],
                                          )
                                        : SizedBox.shrink()
                                  ],
                                )),
                            onTap: () async {
                              final String biometric =
                                  BiometricUtils.getBiometricString(
                                      _biometricType);

                              await BiometricUtils
                                  .showDefaultPopupCheckBiometricAuth(
                                message: 'Please use $biometric to unlock!',
                                callback: (bool result) {
                                  if (result) {
                                    viewModel.setSecurityType(_biometricType);
                                    Router.navigator.pushNamedAndRemoveUntil(
                                        Router.cashHomeScreen,
                                        (Route<dynamic> route) => false);
                                  }
                                },
                              );
                            },
                          ),
                          InkWell(
                            child: Container(
                              height: 60,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              width: MediaQuery.of(context).size.width * .8,
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: const Color(0xFFDCDCDC)))),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(children: [
                                      SvgPicture.asset(
                                          'assets/images/pincode.svg',
                                          color: Colors.black),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(I18n.of(context).pincode,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black))
                                    ]),
                                    !isBiometric
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              SvgPicture.asset(
                                                'assets/images/checkmark.svg',
                                              ),
                                            ],
                                          )
                                        : SizedBox.shrink()
                                  ]),
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PincodeScreen()));
                            },
                          )
                        ],
                      ),
                    );
                  }),
            ],
          ),
        ),
      ],
    );
  }
}

class _SecurityViewModel {
  final Function(BiometricAuth) setSecurityType;
  final BiometricAuth authType;
  _SecurityViewModel({this.setSecurityType, this.authType});

  static _SecurityViewModel fromStore(Store<AppState> store) {
    return _SecurityViewModel(
        authType: store.state.userState.authType,
        setSecurityType: (biometricAuth) {
          store.dispatch(SetSecurityType(biometricAuth: biometricAuth));
        });
  }
}
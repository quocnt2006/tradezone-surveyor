import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:osm_map_surveyor/behaviorsubject/profile_behavior.dart';
import 'package:osm_map_surveyor/bloc/account_bloc.dart';
import 'package:osm_map_surveyor/events/account_event.dart';
import 'package:osm_map_surveyor/models/account.dart';
import 'package:osm_map_surveyor/provider/authentication_provider.dart';
import 'package:osm_map_surveyor/repositories/account_repository.dart';
import 'package:osm_map_surveyor/states/account_state.dart';
import 'package:osm_map_surveyor/utilities/config_base.dart';

enum PictureOption { OpenCamera, OpenGallery}

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _imagePicker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage(storageBucket: Config.storageBucket);

  File imageFile;

  ProfileBehavior _profileBehavior;
  AccountBloc _accountBloc;
  bool _updatingImage = false;
  bool _isUpdate = false;
  bool _updatingInfor = false;
  TextEditingController _fullnameController;
  TextEditingController _phoneNumberController;

  @override
  void initState() {
    super.initState();
    _accountBloc = AccountBloc(accountRepository: AccountRepository());
  }

  @override
  void dispose() {
    super.dispose();
    _accountBloc.close();
    if (_profileBehavior != null) {
      _profileBehavior.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(context),
    );
  }

  Widget body(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        top: true,
        bottom: true,
        left: true,
        right: true,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.95,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: <Widget>[
              accountBlocListener(),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: <Widget>[
                    avatar(context),
                    profileDetails(context),
                  ],
                ),
              ),
              backButton(context),
            ],
          ),
        ),
      ),
    );
  }
  Widget accountBlocListener() {
    return BlocListener(
      bloc: _accountBloc,
      listener: (BuildContext context,AccountState state) {
        if (state is UpdateAccountFinishState) {
          setState(() {
            currentUserWithToken = state.account;
            imageFile = null;
            _updatingImage = false;
            _updatingInfor = false;
            cancelUpdate();
          });
        }
      },
      child: SizedBox(),
    );
  }

  Widget backButton(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.01,
      left: MediaQuery.of(context).size.width * 0.02,
      child: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
          size: MediaQuery.of(context).size.height * 0.025,
        ), 
        onPressed: () {
          Navigator.pop(context);
        }
      ),
    );
  }

  Widget avatar(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Config.secondColor,
      ),
      height: MediaQuery.of(context).size.height * 0.4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            radius: MediaQuery.of(context).size.width * 0.175,
            backgroundImage: 
              imageFile == null
              ? currentUserWithToken.imageUrl != null
                ? NetworkImage(
                  currentUserWithToken.imageUrl,
                )
                : SvgPicture.asset(
                  Config.userSvgIcon,
                  fit: BoxFit.fill,
                )
              : FileImage(
                  imageFile,
                ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          imageFile == null
          ? RaisedButton(
            onPressed: () {
              showImageDialog();
            },
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                MediaQuery.of(context).size.width * 0.02,
              ),
              side: BorderSide(
                color: Config.secondColor,
              ),  
            ), 
            child: Text(
              'Upload image',
              style: TextStyle(
                fontSize: Config.textSizeSmall,
              ),
            ),
          )
          : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  if (!_updatingImage) saveImage();
                },
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.width * 0.035,
                  ),
                  side: BorderSide(
                    color: Config.secondColor,
                  ),
                ), 
                child: Text(
                  'Save',
                  style: TextStyle(
                    fontSize: Config.textSizeSmall,
                  ),
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
              !_updatingImage
              ? RaisedButton(
                onPressed: () {
                  _removeImage();
                },
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.width * 0.035,
                  ),
                  side: BorderSide(
                    color: Config.secondColor,
                  ),
                ), 
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: Config.textSizeSmall,
                  ),
                ),
              )
              : updatingWidget(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget updatingWidget(BuildContext context) {
    return CircularProgressIndicator(
      backgroundColor: Config.thirdColor,
      valueColor: AlwaysStoppedAnimation<Color>(Config.secondColor),
    );
  }

  Widget profileDetails(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.05,
        left: MediaQuery.of(context).size.width * 0.025,
      ),
      child: Column(
        children: <Widget>[
          if (!_isUpdate) showNameWidget(context),
          if (!_isUpdate) SizedBox(
            height: MediaQuery.of(context).size.height * 0.025,
          ),
          if (!_isUpdate) showEmailWidget(context),
          if (!_isUpdate) SizedBox(
            height: MediaQuery.of(context).size.height * 0.025,
          ),
          if (!_isUpdate) showPhoneNumberWidget(context),
          if (_isUpdate) updateProfileWidget(context),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.025,
          ),
          if (_isUpdate) Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              submitUpdateButton(context),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              !_updatingInfor? cancelButton(context) : updatingWidget(context),
            ],
          ),
          if (!_isUpdate) updateButton(context),
        ],
      ),
    );
  }

  Widget showNameWidget(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          Icons.person,
          color: Config.secondColor,
          size: MediaQuery.of(context).size.height * 0.05,
        ),
        Container(
          margin: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * 0.025,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Full name",
                style: TextStyle(
                  fontSize: Config.textSizeSuperSmall,
                  color: Colors.black54,
                ),
              ),
              Text(
                currentUserWithToken.fullname,
                  style: TextStyle(
                    fontSize: Config.textSizeSmall
                  ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget showEmailWidget(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          Icons.mail,
          color: Config.secondColor,
          size: MediaQuery.of(context).size.height * 0.05,
        ),
        Container(
          margin: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * 0.025,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Email",
                style: TextStyle(
                  fontSize: Config.textSizeSuperSmall,
                  color: Colors.black54,
                ),
              ),
              Text(
                currentUserWithToken.email,
                style: TextStyle(
                  fontSize: Config.textSizeSmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget showPhoneNumberWidget(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          Icons.phone,
          color: Config.secondColor,
          size: MediaQuery.of(context).size.height * 0.05,
        ),
        Container(
          margin: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * 0.025,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Phone number",
                style: TextStyle(
                  fontSize: Config.textSizeSuperSmall,
                  color: Colors.black54,
                ),
              ),
              Text(
                currentUserWithToken.phoneNumber,
                style: TextStyle(
                  fontSize: Config.textSizeSmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget updateButton(BuildContext context) {
    return RaisedButton(
      onPressed: () {
        setUpdateProfile();
      },
      color: Config.secondColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02),
      ),
      splashColor: Config.secondColor,
      child: Container(
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.01,
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.01,
        ),
        child: Text(
          'Update Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: Config.textSizeSmall,
          ),
        ),
      ),
    );
  }

  Widget submitUpdateButton(BuildContext context) {
    return StreamBuilder(
      stream: _profileBehavior.submitStream,
      builder: (context, snapshot) {
        return RaisedButton(
          onPressed: snapshot.data == true 
            ? () {
              saveProfile();
            }
            : null,
          color: Config.secondColor,
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02),
          ),
          splashColor: Config.secondColor,
          child: Container(
            child: Text(
              'Submit Update',
              style: TextStyle(
                color: Colors.white,
                fontSize: Config.textSizeSmall,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget cancelButton(BuildContext context) {
    return RaisedButton(
      onPressed: () {
        cancelUpdate();
      },
      color: Config.secondColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02),
      ),
      splashColor: Config.secondColor,
      child: Container(
        child: Text(
          'Cancel',
          style: TextStyle(
            color: Colors.white,
            fontSize: Config.textSizeSmall,
          ),
        ),
      ),
    );
  }

  Widget updateProfileWidget(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          _profileBehavior != null 
          ? StreamBuilder(
            stream: _profileBehavior.fullnameStream,
            builder: (context, snapshot) {
              return TextField(
                autofocus: false,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Config.secondColor,
                    ),
                  ),
                  alignLabelWithHint: false,
                  errorStyle: TextStyle(
                    color: Colors.red,
                    fontSize: Config.textSizeSuperSmall,
                  ),
                  labelText: 'Full name',
                  labelStyle: TextStyle(
                    color: Config.secondColor,
                    fontSize: Config.textSizeSuperSmall,
                  ),
                  icon: Icon(
                    Icons.person,
                    color: Config.secondColor,
                  ),
                  hintText: 'Input the full name',
                  errorText: snapshot.data,
                ),
                controller: _fullnameController,
              );
            },
          )
          : SizedBox(),
          _profileBehavior != null 
          ? StreamBuilder(
            stream: _profileBehavior.phoneNumberStream,
            builder: (context, snapshot) {
              return TextField(
                autofocus: false,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ],
                maxLines: null,
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Config.secondColor,
                    ),
                  ),
                  alignLabelWithHint: false,
                  errorStyle: TextStyle(
                    color: Colors.red,
                    fontSize: Config.textSizeSuperSmall,
                  ),
                  labelText: 'Phone number',
                  labelStyle: TextStyle(
                    color: Config.secondColor,
                    fontSize: Config.textSizeSuperSmall,
                  ),
                  icon: Icon(
                    Icons.phone,
                    color: Config.secondColor,
                  ),
                  hintText: 'Input the phone number',
                  errorText: snapshot.data,
                ),
                controller: _phoneNumberController,
              );
            },
          )
          : SizedBox(),
        ],
      ),
    ); 
  }

  void saveImage() async {
    setState(() {
      _updatingImage = true;
    });
    Account account = new Account();
    account.id = currentUserWithToken.id;
    account.phoneNumber = currentUserWithToken.phoneNumber;
    account.email = currentUserWithToken.email;
    account.role = currentUserWithToken.role;
    account.brandId = currentUserWithToken.brandId;
    account.fullname = currentUserWithToken.fullname;
    StorageReference ref = _storage.ref().child("images/${DateTime.now()}.jpg");
    StorageUploadTask uploadTask = ref.putFile(imageFile);
    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    account.imageUrl = dowurl;
    _accountBloc.add(UpdateAccount(account: account));
  }

  void saveProfile() async {
    setState(() {
      _updatingInfor = true;
    });
    Account account = new Account();
    account.id = currentUserWithToken.id;
    account.phoneNumber = _phoneNumberController.text.toString();
    account.email = currentUserWithToken.email;
    account.role = currentUserWithToken.role;
    account.brandId = currentUserWithToken.brandId;
    account.fullname = _fullnameController.text.toString();
    account.imageUrl = currentUserWithToken.imageUrl;
    _accountBloc.add(UpdateAccount(account: account));
  }

  void setUpdateProfile() {
    setState(() {
      _isUpdate = true;
      _profileBehavior = ProfileBehavior();
      _fullnameController = TextEditingController();
      _phoneNumberController = TextEditingController();
      _fullnameController.addListener(() {
        _profileBehavior.fullnameSink.add(_fullnameController.text);
      });
      _phoneNumberController.addListener(() {
        _profileBehavior.phoneNumberSink.add(_phoneNumberController.text);
      });
      _fullnameController.text = currentUserWithToken.fullname.toString();
      _phoneNumberController.text = currentUserWithToken.phoneNumber.toString();
    });
  }

  void cancelUpdate() {
    setState(() {
      _fullnameController = null;
      _phoneNumberController = null;
      _profileBehavior = null;
      _isUpdate = false;
    });
  }

  void showImageDialog() async {
    switch (await showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Container(
            child: Text(
              "Store image",
              style: TextStyle(
                fontSize: Config.textSizeSmall,
              ),
            ),
          ),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, PictureOption.OpenCamera);
              },
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.photo_camera,
                    color: Config.secondColor,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.02,
                    ),
                    child: Text("Take a photo"),
                  ),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, PictureOption.OpenGallery);
              },
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.photo_library,
                    color: Config.secondColor,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.02,
                    ),
                    child: Text("Take from gallery"),
                  ),
                ],
              ),
            ),
          ],
        );
      })) {
      case PictureOption.OpenCamera:
        _openCamera();
        break;
      case PictureOption.OpenGallery:
        _openGallery();
        break;
    }
  }

  // the function open camera to take a picture
  void _openCamera() async {
    final pickerFile = await _imagePicker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickerFile != null) {
        imageFile = File(pickerFile.path);
      }
    });
  }

  // the function open gallary to select picture
  void _openGallery() async {
    final pickerFile = await _imagePicker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickerFile != null) {
        imageFile = File(pickerFile.path);
      }
    });
  }

  // the function remove Image
  void _removeImage() {
    setState(() {
      imageFile = null;
    });
  }
}
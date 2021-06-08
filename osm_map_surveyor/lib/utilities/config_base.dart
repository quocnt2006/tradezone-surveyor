import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

class Config {
  // text, color format
  static Color firstColor = Color.fromRGBO(128, 173, 215, 1);
  static Color secondColor = Color.fromRGBO(0, 120, 174, 1);
  static Color thirdColor = Color.fromRGBO(235, 242, 234, 1);
  static Color fourthColor = Color.fromRGBO(212, 220, 169, 1);
  static Color fifthColor = Color.fromRGBO(191, 157, 122, 1);
  static Color redColor = Color.fromRGBO(227 , 24, 55, 1);
  static MaterialColor swatchTimePickerColor =
      MaterialColor(0xFF0078AE, <int, Color>{
    50: secondColor,
    100: secondColor,
    200: secondColor,
    300: secondColor,
    400: secondColor,
    500: secondColor,
    600: secondColor,
    700: secondColor,
    800: secondColor,
    900: secondColor,
  });
  static Color iconThemeColor = Colors.white;
  static Color textColorBold = Colors.green[900];
  static Color disableColor = Colors.grey;
  static Color backgroundOpacityColor = Colors.green[100];
  static double textSizeSuperSmall = 15.0;
  static double textSizeSmall = 20.0;
  static double textSizeMedium = 25.0;
  static double textSizeLarge = 35.0;

  // map confix
  static double zoomInit = 16.8;
  static double zoomMax = 19.4;
  static double zoomMin = 15;
  static LatLng initNorthWest = LatLng(10.845326, 106.806853);
  static LatLng initNorthEast = LatLng(10.845326, 106.811268);
  static LatLng initSouthEast = LatLng(10.83783, 106.811268);
  static LatLng initSouthWest = LatLng(10.83783, 106.806853);
  static String urlTemplateOSM = "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png";

  // fourbound of HCM
  static String jsonStringCampus = '107.8890380356461 11.183987034480577, 105.7796630356461 11.183987034480577, 105.7796630356461 10.361050008948766, 107.8890380356461 10.361050008948766, 107.8890380356461 11.183987034480577';

  // maximum floor number
  static int maxFloorNumber = 200;

  // toast
  static int toastLong = 5;

  //firebase
  static String storageBucket = 'gs://loginkhanhnd.appspot.com';

  //svg picture assets
  static String userSvgIcon = 'assets/image/user.svg';
  static String ageCircleSvgIcon = 'assets/image/agecircle.svg';
  static String surveyRequestSvgIcon = 'assets/image/surveyrequest.svg';
  static String buildingSvgIcon = 'assets/image/building.svg';
  static String hospitalSvgIcon = 'assets/image/hospital.svg';
  static String pitchSvgIcon = 'assets/image/pitch.svg';
  static String industrialSvgIcon = 'assets/image/industrial.svg';
  static String supermarketSvgIcon = 'assets/image/supermarket.svg';
  static String serviceSvgIcon = 'assets/image/service.svg';
  static String schoolSvgIcon = 'assets/image/school.svg';
  static String apartmentSvgIcon = 'assets/image/apartment.svg';
  static String shopSvgIcon = 'assets/image/shops.svg';
  static String streetSegmentSvgIcon = 'assets/image/streetsegment.svg';
  static String cancelSvgIcon = 'assets/image/cancel.svg';
  static String floorSvgIcon = 'assets/image/floor.svg';
  static String areaSvgIcon = 'assets/image/area.svg';
  static String draftSvgIcon = 'assets/image/draft.svg';
  static String surveyBuildingSvgIcon = 'assets/image/surveyBuilding.svg';
  static String buildingDefaultSvgIcon = 'assets/image/defaultbuilding.svg';
  static String buildingSurveyedSvgIcon = 'assets/image/surveyedbuilding.svg';
  static String headerBuildingSvgIcon = 'assets/image/headerBuilding.svg';
  static String removeLocationSvgIcon = 'assets/image/remove_location.svg';
  static String headerStoreSvgIcon = 'assets/image/headerstore.svg';
  static String locationSvgIcon = 'assets/image/location.svg';
  static String descriptionSvgIcon = 'assets/image/description.svg';
  static String successSvgIcon = 'assets/image/success.svg';
  static String menuSvgIcon = 'assets/image/menu.svg';
  static String loadingBackgroundImage = 'assets/image/loadingbackground.png';
  static String buildingNeedSurveyPngIcon = 'assets/image/building_need_survey_icon-svg.png';
  static String buildingDefaultPngIcon = 'assets/image/building_default_icon-svg.png';
  static String buildingNeedApprovePngIcon = 'assets/image/building_need_approve_icon-svg.png';
  static String buildingSurveyedPngIcon = 'assets/image/building_surveyed_icon-svg.png';
  static String storeNeedSurveydPngIcon = 'assets/image/store-need-survey.png';
  static String storeDefaultPngIcon = 'assets/image/default-store-surveyed.png';
  static String storeNeedApprovePngIcon = 'assets/image/store-need-approve.png';
  static String logoOfficialPng = 'assets/image/LogoOfficial.png';
  static String brandDefaultPng = 'assets/image/branddefault.png';
  static String historyMapSvgIcon = 'assets/image/historyMapIcon.svg';
  // save building draft string
  static String draftBuilding = 'draftBuilding';
  static String draftBuildingStreetSegment = 'draftBuildingStreetSegment';
  static String draftBuildingPolygonPoints = 'draftBuildingPolygonPoints';
  static String draftUpdateBuilding = 'draftNeedSurveyBuilding';
  static String draftUpdateBuildingStreetSegment = 'draftNeedSurveyBuildingStreetSegment';
  static String draftUpdateBuildingPolygonPoints = 'draftNeedSurveyBuildingPolygonPoints';

  // save store draft string
  static String draftStore = 'draftStore';
  static String draftStoreStreetSegment = 'draftStoreStreetSegment';
  static String draftStorePolygonPoint = 'draftStorePolygonPoint';
  static String draftStoreBuildingId = 'draftStoreBuildingId';
  static String draftStoreFloorNumber = 'draftStoreFloorNumber';
  static String draftUpdateStore = 'draftNeedSurveyStore';
  static String draftUpdateStoreStreetSegment = 'draftStoreStreetSegment';
  static String draftUpdateStorePolygonPoint = 'draftStorePolygonPoint';
  static String draftUpdateStoreBuildingId = 'draftStoreBuildingId';
  static String draftUpdateStoreFloorNumber = 'draftStoreFloorNumber';

  // button text
  static String uploadImage = 'Upload image';
  static String sorryHeader = 'Sorry';
  static String noticeHeader = 'Notice';
  static String errorLogin = 'Login error';
  static String errorBody = 'Error to login!';
  static String loadingBrandStoreFail = 'Load failed';
  static String loadingBrandStoreFailBody = 'Load stores of this brand failed';
  static String loadingSystemZoneStoreFail = 'Load failed';
  static String loadingSystemZoneStoreFailBody = 'Load stores of this system zone failed';
  static String loadingSystemZoneBuildingFail = 'Load failed';
  static String loadingSystemZoneBuildingFailBody = 'Load buildings of this system zone failed';
  static String loadingSystemZoneFail = 'Load failed';
  static String loadingSystemZoneFailBody = 'Load system zone failed. Try again!';
  static String loadingFail = 'Loading failed';
  static String loadingFailBody = 'Loading failed, try log in after seconds';
  static String failLogin = 'Login failed';
  static String failBody = 'You do not have permission to login to this app!';
  static String checkStoreFail = 'Check failed';
  static String checkStoreFailBody = 'Check store location failed, please try again!';
  static String checkCampusFail = 'Check failed';
  static String checkCampusFailBody = 'Check campus failed, please try again!';
  static String invalidStore = 'Invalid';
  static String invalidStoreBody = 'Invalid store location, select store location again!';
  static String invalidBuilding = 'Invalid';
  static String invalidBuildingBody = 'Invalid building base, redraw building base!';
  static String notAdminBody = 'You do not have permission to login to this app!';
  static String somethingWrongBody = 'Username or password is wrong!';
  static String sessionTimeOut = 'Token expired!';
  static String addBuildingHeader = 'Are you sure?';
  static String addBuildingMessage = 'Create building';
  static String saveDraftBuildingHeader = 'Are you sure?';
  static String saveDraftBuildingMessage = 'Save draft building';
  static String updateBuildingHeader = 'Are you sure?';
  static String updateBuildingMessage = 'Update building';
  static String updateSegmentHeader = 'Are you sure?';
  static String updateSegmentMessage = 'Update this segment';
  static String createSegmentSuccessMessage = 'Create building segment successful';
  static String deleteSegmentSuccessMessage = 'Delete building segment successful';
  static String deleteDraftBuildingHeader = 'Are you sure?';
  static String deleteDraftBuildingMessage = 'Delete draft building';
  static String deleteDraftStoreHeader = 'Are you sure?';
  static String deleteDraftStoreMessage = 'Delete draft store';
  static String deleteStoreHeader = 'Are you sure?';
  static String deleteStoreMessage = 'Delete store';
  static String deleteBuildingCategoryHeader = 'Are you sure?';
  static String deleteBuildingCategoryMessage = 'Delete this segment';
  static String deleteBuildingHeader = 'Are you sure?';
  static String deleteFloorAreaHeader = 'Delete floor area?';
  static String deleteFloorAreaBody = 'Delete floor area';
  static String deleteFloorHeader = 'Delete floor?';
  static String deleteFloorBody = 'Delete floor';
  static String deleteBuildingMessage = 'Delete building';
  static String saveDraftBuildingSuccessMessage = 'Save draft building success';
  static String saveDraftStoreSuccessMessage = 'Save draft building successful';
  static String rejectSurveyRequestSuccessMessage = 'Reject survey request success';
  static String rejectSurveyRequestFailMessage = 'Reject survey request fail';
  static String acceptSurveyRequestSuccessMessage = 'Accept survey request success';
  static String acceptSurveyRequestFailMessage = 'Accept survey request fail';
  static String addStoreSuccessMessage = 'Add store success';
  static String saveBuildingAnalysisSuccessMessage = 'Save building analysis success';
  static String saveNeedSurveyDraftBuildingSuccessMessage = 'Save draft need survey building success';
  static String saveNeedSurveyDraftStoreSuccessMessage = 'Save draft need survey store success';
  static String addStoreHeader = 'Are you sure?';
  static String addStoreMessage = 'Add store';
  static String updateStoreHeader = 'Are you sure?';
  static String updateStoreMessage = 'Update store';
  static String saveDraftStoreHeader = 'Are you sure?';
  static String saveDraftStoreMessage = 'Save draft store';
  static String saveBuildingAnalysisHeader = 'Are you sure?';
  static String saveBuildingAnalysisMessage = 'Save building analysis';
  static String updateNeedSurveyBuildingSuccessMessage = 'Update building successful';
  static String updateNeedSurveyStoreSuccessMessage = 'Update store success';
  static String addBuildingSuccessMessage = 'Create building successful';
  static String updateFloorSuccessMessage = 'Update floor success';
  static String deleteFloorSuccessMessage = 'Delete floor success';
  static String deleteDraftBuildingSuccessMessage = 'Delete draft building successful';
  static String deleteBuildingSuccessMessage = 'Delete building request is sent';
  static String deleteStoreSuccessMessage = 'Delete store request is sent';
  static String deleteBuildingFailMessage = 'Delete building request is fail';
  static String deleteStoreFailMessage = 'Delete store request is fail';
  static String addFloorSuccessMessage = 'Add floor success';
  static String updateFloorAreaSuccessMessage = 'Update floor area success';
  static String deleteFloorAreaSuccessMessage = 'Delete floor area success';
  static String addFloorAreaSuccessMessage = 'Add floor area success';
  static String noFloorAvailableMessage = 'No floor available';
  static String noFloorAreaAvailableMessage = 'No floor area available';
  static String noStorevailableMessage = 'No store available';
  static String locationNoAvailableMessage = 'Location is not available';
  static String rejectSurveyRequestHeader = 'Note';
  static String okButtonPopup = 'Ok';
  static String addButtonPopup = 'Add';
  static String createButtonPopup = 'Create';
  static String updateButtonPopup = 'Update';
  static String saveButtonPopup = 'Save';
  static String submitButtonPopup = 'Submit';
  static String deleteButtonPopup = 'Delete';
  static String cancelButtonPopup = 'Cancel';

  // sub header context
  static String subHeaderDraftBuildingContext = "Draft building";
  static String subHeaderNeedSurveyBuildingContext = "Need survey building";
  static String subHeaderDraftStoreContext = "Draft store";
  static String subHeaderNeedSurveyStoreContext = "Need survey store";
}

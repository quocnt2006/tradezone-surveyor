class BaseUrl {
  static String versionApi = "v1.0";
  static String base = "https://trade-zone-team.azurewebsites.net/api/" + versionApi + "/";

  // acccounts
  static String accountsbase = base + "accounts/";
  static String authenticate = accountsbase + "authenticate";
  static String verifyJwt = accountsbase + "verify-jwt";
  static String accountbyid(String id) {
    return accountsbase + id;
  }

  // brands
  static String brandsbase = base + "brands/";
  static String listbrandstores(int id) {
    return brandsbase + id.toString() + '/stores';
  }
  static String brands = base + "brands";

  // buildings
  static String buildingsbase = base + "buildings/";
  static String buildings = base + "buildings";
  static String listbuildingtypes = buildingsbase + "types";
  static String buildingsneedsurveybase = buildingsbase + "building-need-survey/";
  static String buildingsneedsurveyor =  buildingsneedsurveybase + "surveyor?Status=2";
  static String needsurveybuilding = buildingsbase + "need-survey/";
  static String analysisbuilding = buildingsbase + "analysis";
  static String analysisbuildingbase = buildingsbase + "analysis/";
  static String needsurveybuildingbyid(String id) {
    return needsurveybuilding + id;
  }
  static String buildingbyid(int id) {
    return buildingsbase + id.toString();
  }
  static String liststreetsegmentbybuildingid(int id) {
    return buildingsbase + id.toString() + '/street-segments';
  }
  static String listBuildingAnalysis(int id) {
    return analysisbuildingbase + id.toString();
  }
  static String buildingAnalysisById(int buildingId, int categoryId) {
    return analysisbuildingbase + buildingId.toString() + '/' + categoryId.toString();
  }

  // segment
  static String segment = base + "segment";

  // district
  static String districtbase = base + "districts/";
  static String getdistrict = districtbase + "map";

  // store
  static String storesbase = base + "stores/";
  static String stores = base + "stores";
  static String getstores = storesbase + "map";
  static String getstoresbybrandid = storesbase + "get-store-by-brand-id";
  static String storebyid(int id) {
    return storesbase + id.toString();
  }
  static String storesneedsurveybase = storesbase + "store-need-survey/";
  static String storetypes = storesbase + "types";
  static String liststorebuildings = storesbase + "buildings";
  static String storesneedsurveyor =  storesneedsurveybase + "surveyor?Status=2";
  static String liststreetsegmentbystoreid(int id) {
    return storesbase + id.toString() + '/street-segments';
  }

  // street segments
  static String streetsegmentbase = base + "street-segments/";
  static String liststreetsegment = streetsegmentbase + "map";
  static String liststreetsegmentbypoint = streetsegmentbase + "store";
  static String streetsegment = base + "street-segments";

  // map
  static String mapbase = base + "map/";
  static String mapcampus = mapbase + "campus";
  static String mapstore = mapbase + "store";
  static String mapbuildings = mapbase + "building";
  static String wardmapbase = mapbase + "ward/";
  static String getbuildingcampus =  wardmapbase + "check-building-valid";
  static String systemzonemapbase = mapbase + "system-zone/";
  static String needsurveysystemzonemap = systemzonemapbase + "surveyor";
  static String mapbuildingbase = mapbase + "building/";
  static String needsurveybuildingmap = mapbuildingbase + "surveyor";
  static String mapstorebase = mapbase + "store/";
  static String needsurveystoremap = mapstorebase + "surveyor";
  static String surveyrequestmap = mapbase + "survey-request";
  static String storevalidmap = mapbase + "store-valid";
  static String storevalidmapbylocation(String str) {
    return storevalidmap + '?coordinateString=' + str;
  }

  // survey request
  static String surveyrequestbase = base + "survey-request/";
  static String approvalsurveyrequest = surveyrequestbase + "approval/";
  static String approvalsurveyrequestid(int id) {
    return approvalsurveyrequest + id.toString();
  }
  static String surveyrequestbyid(int id) {
    return surveyrequestbase + id.toString();
  }

  // history
  static String history = base + "history?SortType=1&ColName=CreateDate";

  // wards
  static String wards = base + "wards";

  // system zone
  static String systemzones = base + "system-zones";
  static String systemzonesbase = base + "system-zones/";
  static String pagingsystemzones(int districtId, int page, int pageSize, bool isMe) {
    return systemzones + "?" 
      + (districtId != null? ("DistrictId=" + districtId.toString() + '&') : '') 
      + "Page=" + page.toString() + "&PageSize=" + pageSize.toString()
      + (isMe == null? '' : ('&IsMe=' + isMe.toString()));
  }
  static String systemzonebuildings(int id, int page, int pageSize) {
    return systemzonesbase + id.toString() + "/buildings" + "?Page=" + page.toString() + "&PageSize=" + pageSize.toString();
  }
  static String systemzonestores(int id, int page, int pageSize) {
    return systemzonesbase + id.toString() + "/stores" + "?Page=" + page.toString() + "&PageSize=" + pageSize.toString();
  }
}

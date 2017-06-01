include "CKAN_Server.iol"
include "console.iol"


interface ExternalCKANServerIface {
RequestResponse:
	site_read(GetSiteReadRequest)(GetSiteReadResponse),
	package_list(GetPackageListRequest)(GetPackageListResponse),
	current_package_list_with_resources(GetCurrentPackageListWithResourcesRequest)(GetCurrentPackageListWithResourcesResponse),
	revision_list(GetRevisionListRequest)(GetRevisionListResponse),
	package_revision_list(GetPackageRevisionListRequest)(GetPackageRevisionListResponse),
	related_show(GetRelatedShowRequest)(GetRelatedShowResponse),
	related_list(GetRelatedListRequest)(GetRelatedListResponse),
	member_list(GetMemberListRequest)(GetMemberListResponse),
	group_list(GetGroupListRequest)(GetGroupListResponse),
	organization_list(GetOrganizationListRequest)(GetOrganizationListResponse),
	group_list_authz(GetGroupListAuthzRequest)(GetGroupListAuthzResponse),
	organization_list_for_user(GetOrganizationListForUserRequest)(GetOrganizationListForUserResponse),
	group_revision_list(GetGroupRevisionListRequest)(GetGroupRevisionListResponse),
	organization_revision_list(GetorganizationRevisionListRequest)(GetorganizationRevisionListResponse),
	license_list(GetLicenseListRequest)(GetLicenseListResponse),
	tag_list(GetTagListRequest)(GetTagListResponse),
	user_list(GetUserListRequest)(GetUserListResponse),
	package_relationships_list(GetPackageRelationshipsListRequest)(GetPackageRelationshipsListResponse),
	package_show(GetPackageShowRequest)(GetPackageShowResponse),
	// TODO: Implement the last get methods

	package_create(CreatePackageCreateRequest)(CreatePackageCreateResponse),
	resource_create(CreateResourceCreateRequest)(CreateResourceCreateResponse)
}

outputPort ExternalCKANServer {
	Protocol: http {
		.osc.site_read.method = "get";
		.osc.package_list.method = "get";
		.osc.current_package_list_with_resources.method = "get";
		.osc.revision_list.method = "get";
		.osc.package_revision_list.method = "get";
		.osc.related_show.method = "get";
		.osc.related_list.method = "get";
		.osc.member_list.method = "get";
		.osc.group_list.method = "get";
		.osc.organization_list.method = "get";
		.osc.group_list_authz.method = "get";
		.osc.organization_list_for_user.method = "get";
		.osc.group_revision_list.method = "get";
		.osc.organization_revision_list.method = "get";
		.osc.license_list.method = "get";
		.osc.tag_list.method = "get";
		.osc.user_list.method = "get";
		.osc.package_relationships_list.method = "get";
		.osc.package_show.method = "get";
		// TODO : Implement the last get methods
		.osc.package_create.method = "post";
		.osc.resource_create.method = "post";

		.format -> format;
		.addHeader -> addHeader;
		.debug = true;
		.debug.showContent = true
	}
	Interfaces: ExternalCKANServerIface
}

inputPort CKANServerInput {
	Location: Location_CKANServer
	Protocol: sodep
	Interfaces: CKANServerIface
}

execution { concurrent }

init
{
	format = "json";
	configure( conf )() {
		ExternalCKANServer.location = conf.location;
		global.config << conf
	}
}

main
{
	// Get methods:
	[ get_site_read( request )( response ){
		site_read@ExternalCKANServer( request )( response )
	} ]
	[ get_package_list( request )( response ) {
		package_list@ExternalCKANServer( request )( response )
	} ]
	[ get_current_package_list_with_resources( request )( response ) {
		current_package_list_with_resources@ExternalCKANServer( request )( response )
	} ]
	[ get_revision_list( request )( response ) {
		revision_list@ExternalCKANServer( request )( response )
	} ]
	[ get_package_revision_list( request )( response ) {
		package_revision_list@ExternalCKANServer( request )( response )
	} ]
	[ get_related_show( request )( response ) {
		related_show@ExternalCKANServer( request )( response )
	} ]
	[ get_related_list( request )( response ) {
		related_list@ExternalCKANServer( request )( response )
	} ]
	[ get_member_list( request )( response ) {
		member_list@ExternalCKANServer( request )( response )
	} ]
	[ get_group_list( request )( response ) {
		group_list@ExternalCKANServer( request )( response )
	} ]
	[ get_organization_list( request )( response ) {
		organization_list@ExternalCKANServer( request )( response )
	} ]
	[ get_group_list_authz( request )( response ) {
		group_list_authz@ExternalCKANServer( request )( response )
	} ]
	[ get_organization_list_for_user( request )( response ) {
		organization_list_for_user@ExternalCKANServer( request )( response )
	} ]
	[ get_group_revision_list( request )( response ) {
		group_revision_list@ExternalCKANServer( request )( response )
	} ]
	[ get_organization_revision_list( request )( response ) {
		organization_revision_list@ExternalCKANServer( request )( response )
	} ]
	[ get_license_list( request )( response ) {
		license_list@ExternalCKANServer( request )( response )
	} ]
	[ get_tag_list( request )( response ) {
		tag_list@ExternalCKANServer( request )( response )
	} ]
	[ get_user_list( request )( response ) {
		user_list@ExternalCKANServer( request )( response )
	} ]
	[ get_package_relationships_list( request )( response ) {
		package_relationships_list@ExternalCKANServer( request )( response )
	} ]
	[ get_package_show( request )( response ) {
		package_show@ExternalCKANServer( request )( response )
	} ]

	// TODO : Implement the last get methods

	// Create methods:
	[ create_package_create( request )( response ) {
		addHeader.header = "Authorization";
		addHeader.header.value = request.api_key;
		undef(request.api_key);
		package_create@ExternalCKANServer( request )( response )
	} ]
	[ create_resource_create( request )( response ) {
		addHeader.header = "Authorization";
		addHeader.header.value = request.api_key;
		undef(request.api_key);
		format = "multipart/form-data";
		resource_create@ExternalCKANServer( request )( response )
	} ]
}

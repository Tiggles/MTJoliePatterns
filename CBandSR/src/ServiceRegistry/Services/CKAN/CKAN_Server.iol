constants {
	Location_CKANServer = "socket://localhost:9012"
}

type CKANServerConfiguration:void {
	.location:string
}

type GetSiteReadRequest:void

type GetSiteReadResponse:void {
	.help:string
	.success:bool
	.result:bool
}

type GetPackageListRequest:void {
	.limit?:int
	.offset?:int
}

type GetPackageListResponse:void {
	.help:string
	.success:bool
	.result*:string
}

type GetCurrentPackageListWithResourcesRequest:void {
	.limit?:int
	.offset?:int
	.page?:int
}

type GetCurrentPackageListWithResourcesResponse:void {
	.help:string
	.success:bool
	.result*:undefined // TODO: Write this type
}

type GetRevisionListRequest:void

type GetRevisionListResponse:void {
	.help:string
	.success:bool
	.result*:string
}

type GetPackageRevisionListRequest:void{
	.id:string
}

type GetPackageRevisionListResponse:void {
	.help:string
	.success:bool
	.result*:void{
		.id:string
		.timestamp:string
		.message:string
		.author:string
		.approved_timestamp:undefined // TODO: Write this type
	}
	// TODO: Write type for error:
	/*
		"error": {"message": "Not found", "__type": "Not Found Error"}
	 */
}

type GetRelatedShowRequest:void{
	.id:string
}

type GetRelatedShowResponse:undefined // TODO: Write this type

type GetRelatedListRequest:undefined // TODO: Write this type

type GetRelatedListResponse:undefined // TODO: Write this type

type GetMemberListRequest:undefined // TODO: Write this type

type GetMemberListResponse:undefined // TODO: Write this type

type GetGroupListRequest:undefined // TODO: Write this type

type GetGroupListResponse:undefined // TODO: Write this type

type GetOrganizationListRequest:undefined // TODO: Write this type

type GetOrganizationListResponse:undefined // TODO: Write this type

type GetGroupListAuthzRequest:undefined // TODO: Write this type

type GetGroupListAuthzResponse:undefined // TODO: Write this type

type GetOrganizationListForUserRequest:undefined // TODO: Write this type

type GetOrganizationListForUserResponse:undefined // TODO: Write this type

type GetGroupRevisionListRequest:undefined // TODO: Write this type

type GetGroupRevisionListResponse:undefined // TODO: Write this type

type GetorganizationRevisionListRequest:undefined // TODO: Write this type

type GetorganizationRevisionListResponse:undefined // TODO: Write this type

type GetLicenseListRequest:undefined // TODO: Write this type

type GetLicenseListResponse:undefined // TODO: Write this type

type GetTagListRequest:undefined // TODO: Write this type

type GetTagListResponse:undefined // TODO: Write this type

type GetUserListRequest:undefined // TODO: Write this type

type GetUserListResponse:undefined // TODO: Write this type

type GetPackageRelationshipsListRequest:undefined // TODO: Write this type

type GetPackageRelationshipsListResponse:undefined // TODO: Write this type

type GetPackageShowRequest:undefined // TODO: Write this type

type GetPackageShowResponse:undefined // TODO: Write this type

// TODO : Implement the last get types

type CreatePackageCreateRequest:undefined // TODO: Write this type

type CreatePackageCreateResponse:undefined // TODO: Write this type

type CreateResourceCreateRequest:undefined // TODO: Write this type

type CreateResourceCreateResponse:undefined // TODO: Write this type


interface CKANServerIface {
RequestResponse:

	configure(CKANServerConfiguration)(void),

	get_site_read(GetSiteReadRequest)(GetSiteReadResponse),
	get_package_list(GetPackageListRequest)(GetPackageListResponse),
	get_current_package_list_with_resources(GetCurrentPackageListWithResourcesRequest)(GetCurrentPackageListWithResourcesResponse),
	get_revision_list(GetRevisionListRequest)(GetRevisionListResponse),
	get_package_revision_list(GetPackageRevisionListRequest)(GetPackageRevisionListResponse),
	get_related_show(GetRelatedShowRequest)(GetRelatedShowResponse),
	get_related_list(GetRelatedListRequest)(GetRelatedListResponse),
	get_member_list(GetMemberListRequest)(GetMemberListResponse),
	get_group_list(GetGroupListRequest)(GetGroupListResponse),
	get_organization_list(GetOrganizationListRequest)(GetOrganizationListResponse),
	get_group_list_authz(GetGroupListAuthzRequest)(GetGroupListAuthzResponse),
	get_organization_list_for_user(GetOrganizationListForUserRequest)(GetOrganizationListForUserResponse),
	get_group_revision_list(GetGroupRevisionListRequest)(GetGroupRevisionListResponse),
	get_organization_revision_list(GetorganizationRevisionListRequest)(GetorganizationRevisionListResponse),
	get_license_list(GetLicenseListRequest)(GetLicenseListResponse),
	get_tag_list(GetTagListRequest)(GetTagListResponse),
	get_user_list(GetUserListRequest)(GetUserListResponse),
	get_package_relationships_list(GetPackageRelationshipsListRequest)(GetPackageRelationshipsListResponse),
	get_package_show(GetPackageShowRequest)(GetPackageShowResponse),
	// TODO: Implement the last get methods
	create_package_create(CreatePackageCreateRequest)(CreatePackageCreateResponse),
	create_resource_create(CreateResourceCreateRequest)(CreateResourceCreateResponse)
}

outputPort CKANServer {
Location: Location_CKANServer
Protocol: sodep
Interfaces: CKANServerIface
}

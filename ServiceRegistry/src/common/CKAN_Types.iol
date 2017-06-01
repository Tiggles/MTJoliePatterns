type FeatureCollection:void {
	.type:string
	.features*:void {
		.type:string
		.id:string
		.geometry:void {
			.type:string
			.coordinates[2,2]:double
		}
		.geometry_name:string
		.properties:undefined
	}
	.crs:void{
		.type:string
		.properties:void{
			.code:string
		}
	}
	.bbox[ 4, 4]:double
}

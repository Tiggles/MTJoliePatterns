include "types/Binding.iol"

type AuthenticationKeyRequest: void {
    .name:string
    .email:string
}

type AuthenticationKeyResponse: void {
    .authenticationString:string
}

type RegisterRequest:void {
    .binding:Binding
    .serviceName:string
    .interfacefile?:string | void
    .docFile?:string  | void
    .authenticationKey:string
}

type DeregisterRequest:void {
    .id:long
    .authenticationString:string
}

type OwnerRequest: void {
    .name:string
    .email:string
}

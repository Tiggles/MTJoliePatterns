outputPort GenericHTTP {
    Protocol: https { .debug.showContent = .debug = false; .method = "get" }
    RequestResponse: download
}

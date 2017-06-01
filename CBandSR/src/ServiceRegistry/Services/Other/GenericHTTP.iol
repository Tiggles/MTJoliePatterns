outputPort GenericHTTP {
    Protocol: http { .debug.showContent = .debug = false; .method = "get"; .format = "json" }
    RequestResponse: download
}

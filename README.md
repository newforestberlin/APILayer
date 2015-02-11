# APILayer
Sources for API layers we use in iOS apps, based on Alamofire (https://github.com/Alamofire/Alamofire).

You might need to build Alamofire with 'carthage update'.
See https://github.com/Carthage/Carthage for more details on carthage.


The class RequestParameterMapper allows very flexible mapping of custom entities to encodeable objects,
which is handy if you are using URL encoding for example:

    // Parameter mapper, initialized with the API specific parameter mappers (static because shared)
    private static var parameterMapper = RequestParameterMapper(
        methods: [

            // Mapper method for string values
            (
                filterMethod: {(item: AnyObject) -> Bool in return (item as? String) != nil},
                constructMethod: {(item: AnyObject) -> AnyObject in return item as String }
            ),

            // Mapper method for arrays of strings (turns them into joined string)
            (
                filterMethod: {(item: AnyObject) -> Bool in return (item as? [String]) != nil},
                constructMethod: {(item: AnyObject) -> AnyObject in return ",".join(item as [String]) }
            )
        ]
    )

Then during request construction in the Router we use this parameterMapper to fill the params dictionary before encoding:


    // Add mapped parameters to params dictionary.
    params += Router.parameterMapper.parameterize(
        (paramKeys.firstName, firstName),
        (paramKeys.lastName, lastName),
        (paramKeys.tags, tags)
    )

    // The parameterMapper must guarantee that all objets put into the params dictionary are encodeable by this method.
    return ParameterEncoding.URL.encode(mutableURLRequest, parameters: params).0

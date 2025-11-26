app.factory("TranslateService", function ($http, $q) {
    let dictionary = {};

    return {
        loadLanguage: function (lang) {
            let deferred = $q.defer();

            // 🔥 ĐƯỜNG DẪN ĐÚNG THEO CẤU TRÚC THƯ MỤC
            $http.get("../Shared/lang/" + lang.toLowerCase() + ".json")
                .then(function (res) {
                    dictionary = res.data;
                    deferred.resolve();
                }, function (err) {
                    console.error("Translation load fail:", err);
                    deferred.reject(err);
                });

            return deferred.promise;
        },

        t: function (key) {
            return dictionary[key] || key;
        }
    };
});

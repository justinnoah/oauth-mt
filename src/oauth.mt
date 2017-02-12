import "lib/codec/percent" =~ [=> PercentEncoding :DeepFrozen]
import "lib/entropy/entropy" =~ [=> makeEntropy :DeepFrozen]
import "lib/entropy/pcg" =~ [=> makePCG :DeepFrozen]

import "http/client" =~ [=> makeRequest :DeepFrozen]
import "url/url" =~ [=> makeParsedURL :DeepFrozen, => parse_qs :DeepFrozen]

exports (main)


def OAUTH2_VERSION := "1.0"
def DEFAULT_POST_CONTENT_TYPE := "application/x-www-form-urlencoded"
def HTTP_METHOD := "GET"
def SIGNATURE_METHOD := "PLAINTEXT"


def makeConsumer(key :Str, secret :Str) as DeepFrozen:
    ""
    return object Consumer:
        to urlEncode() :Str:
            def encoded := PercentEncoding.encode(
                `key=$key&secret=$secret`, null)
            return encoded

        to key() :Str:
            return key

        to secret() :Str:
            return secret

        to toString() :Str:
            return Consumer.urlEncode()


def makeToken(key :Str, secret :Str) as DeepFrozen:
    ""
    var verifier :NullOk[Str] := null

    return object Token:
        to urlEncode() :Str:
            def encoded := PercentEncoding.encode(
                `key=$key&secret=$secret`, null)
            return encoded

        to setVerifier(v :NullOk[Str]):
            switch (v):
                match ==null:
                    # XXX: FIX
                    # create a random string
                    def rng := makeEntropy(makePCG(0x0, 0))
                    def nums := [].diverge()
                    for _ in (0..!9):
                        def n := rng.nextInt(9)
                        nums.add(n)
                    def intStr := "".join([for n in (nums) `$n`])
                    verifier := intStr
                match x:
                    verifier := x

        to toString() :Str:
            return Token.urlEncode()


object Request:
    to from_consumer_and_token(consumer, token, http_method :Str,
        url :NullOk[Str], parameters :NullOk[Map[Str, Str]], body :Bytes,
        is_form_encoded :Bool):
        var defaults := [
            "oauth_consumer_key" => consumer.key(),
            "oauth_timestamp" => Request.makeTimestamp(),
            "oauth_nonce" => Request.makeNonce(),
            "oauth_version" => OAUTH2_VERSION
        ].asMap()

        switch (parameters):
            match m :Map:
                for k => v in (m):
                    defaults[k] := v

        if (token != null):
            defaults["oauth_token"] := token.key()

    to makeTimestamp():
        "Awaiting Language Implementation."
        return 0

    to makeNonce():
        "Generate a psuedorandom number."

        # XXX: FIX
        def rng := makeEntropy(makePCG(0x0, 0))
        def nonce := rng.nextInt(100000000)
        return `$nonce`



def makeClient(key :Str, secret :Str) as DeepFrozen:
    ""
    def consumer := makeConsumer(key, secret)
    def token := null
    return object Client:
        to request(_uri :Str, _meth: Str, _body :Bytes, _headers :Map[Str, Str]):
            var uri := _uri
            var meth := _meth
            var body := _body
            var headers := _headers

            var is_form_encoded :Bool := false
            var parameters := [].asMap()
            if (_meth == "POST"):
                headers["Content-Type"] := DEFAULT_POST_CONTENT_TYPE
                is_form_encoded := true
                def parameters := parse_qs(parameters)

            def req := Request.from_consumer_and_token(
                consumer, token, meth, uri, parameters, body, is_form_encoded)

            # req.sign_request()

            def url := makeParsedURL(uri)
            def oauth_realm := url.realm()
            if (is_form_encoded):
                body := req.to_postdata()
            else if (meth != "GET"):
                headers["realm"] := oauth_realm

            # makeRequest should maybe be rewritten to *not*
            # require an endpoint maker
            # def httpReq := makeRequest()
            # return httpReq.m`$meth.toLowerCase()`()


def main(argv):
    return 0

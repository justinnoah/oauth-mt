import "lib/codec/percent" =~ [=> PercentEncoding]

import "http/client" =~ [=> makeRequest :DeepFrozen]

exports (main)


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
    return object Token:
        to urlEncode() :Str:
            def encoded := PercentEncoding.encode(
                `key=$key&secret=$secret`, null)
            return encoded

        to toString() :Str:
            return Token.urlEncode()


object Request:
    to from_consumer_and_token(
        consumer :Consumer, token :Any[Token, Void], http_method :Str,
        url :Any[Str, Void], parameters :Any[Map[Str, Any], Void], body :Bytes,
        is_form_encoded :Bool
    ):
        defaults := [
            "oauth_consumer_key" => consumer.key(),
            "oauth_timestamp" => Request.makeTimestamp(),
            "oauth_nonce" => Request.makeNonce(),
            "oauth_version" => "1.0",
        ].asMap()

    to makeTimestamp():
        return 0

    to makeNonce():
        return 0


def makeRequest(meth, url, parameters, body, is_form_encoded) :Request as DeepFrozen:
    ""
    return Request


def makeClient(key :Str, secret :Str) :Client as DeepFrozen:
    ""
    def consumer :Consumer := makeConsumer(key, secret)
    def token := null

    return object Client:
        to request(uri :Str, meth, body :Bytes, headers :Map):
            if (meth == "POST"):
                headers["Content-Type"] := "application/x-www-form-urlencoded"

def main():
    return 0

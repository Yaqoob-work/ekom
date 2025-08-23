Release Files
-------------

    Included is generated SRI hashes of the built files for security integrity within the file sri-directives.json

    Example include of the files with generated hashes for integrity of manipulation is

    ```
    <script src="js/pluginfile.js"
        integrity="sha512-lXGcxyXwMOSK5tj+8cC3bUAD7rF6BaxzxGgkNkPER8oGRcXTjqyV2SNKH6DYX3KysuVWZlP7yghxo59YUFToWw=="
        crossorigin="anonymous"></script> 
    ```

    Where the hash is obtained from the integrity field

    ```
     "payload": {
        "@youtube": {
          "hashes": {
            "sha512": "lXGcxyXwMOSK5tj+8cC3bUAD7rF6BaxzxGgkNkPER8oGRcXTjqyV2SNKH6DYX3KysuVWZlP7yghxo59YUFToWw=="
          },
          "integrity": "sha512-lXGcxyXwMOSK5tj+8cC3bUAD7rF6BaxzxGgkNkPER8oGRcXTjqyV2SNKH6DYX3KysuVWZlP7yghxo59YUFToWw==",
          "path": "build/youtube-7.2.6.js"
        }
      }
    ```


    See: https://developer.mozilla.org/en-US/docs/Web/Security/Subresource_Integrity


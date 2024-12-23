# API-README

Document of the site's API that nhviewer might use.

## Useful URL

- Comic list of search
  - https://nhentai.net/api/galleries/search?query=chinese
  - https://nhentai.net/api/galleries/search?query=english
  - https://nhentai.net/api/galleries/search?query=japanese
  - https://nhentai.net/api/galleries/search?query=-
- Thumbnails
  - https://t1.nhentai.net/galleries/$mid/thumb.$ext
  - https://t2.nhentai.net/galleries/$mid/thumb.$ext
  - https://t3.nhentai.net/galleries/$mid/thumb.$ext nhv is currently hardcoded this one as workaround
  - https://t4.nhentai.net/galleries/$mid/thumb.$ext
  - obsoleted? https://t.nhentai.net/galleries/$mid/thumb.$ext
- Inner page
  - https://i1.nhentai.net/galleries/$mid/thumb.$ext
  - https://i2.nhentai.net/galleries/$mid/thumb.$ext
  - https://i3.nhentai.net/galleries/$mid/thumb.$ext nhv is currently hardcoded this one as workaround
  - https://i4.nhentai.net/galleries/$mid/thumb.$ext
  - obsoleted? https://i.nhentai.net/galleries/$mid/$page.$ext
- ...

## API issues with language keywords

In recent years, certain query string trigger an empty response randomly. This may affect searching and language filtering. As a workaround, the app now store some query alternatives. It may switch to these language keywords when needed.

> Example of search api: https://nhentai.net/api/galleries/search?query=language:chinese

- Alternatives
  - -language:english -language:japanese
  - chinese
  - 汉化
  - 中国

> Example tag api https://nhentai.net/api/galleries/tagged?tag_id=29963&page=1

Calling tag api is another solution, worth trying when search is not available. Currently the app is not using this one though.

---

## Reference - Links for testing

https://nhentai.net/api/galleries/search?query=-language:english%20-language:japanese
https://nhentai.net/search/?q=-language%3Aenglish+-language%3Ajapanese

- same with index
https://nhentai.net/search/?q=-

## Reference - api summary from Perplexity

> prompt: what api endpoint does nhentai has

nhentai has an API endpoint for its galleries, which is located at "https://nhentai.net/api"[2]. Additionally, there are specific endpoints within the nhentai API, such as:
- Endpoint for individual galleries: "https://nhentai.net/api/gallery"[2]
- Endpoint for multiple galleries: "https://nhentai.net/api/galleries"[2]
- Search API endpoint: "https://nhentai.net/api/galleries/search"[2]
- Endpoint for tagged galleries: "https://nhentai.net/api/galleries/tagged"[2]
- Endpoint for all galleries: "https://nhentai.net/api/galleries/all"[2]

Citations:
[1] https://github.com/topics/nhentai-api
[2] https://pkg.go.dev/gitlab.com/lamados/go-nhentai
[3] https://pypi.org/project/NHentai-API/
[4] https://docs.rs/hentai/latest/hentai/
[5] https://crates.io/crates/hentai/0.2.2
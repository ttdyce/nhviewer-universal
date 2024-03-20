# concept_nhv

A complete rewrite of NHViewer 2, with flutter. Featuring Material Design 3, 

## language keywords

> https://nhentai.net/api/galleries/search?query=??

- chinese
- language:chinese
- 中国

> https://nhentai.net/api/galleries/tagged?tag_id=29963&page=1
> It is also chinese, with the tagged api, worth trying when search is not available

## features

- 

## APIs

- Comic list of search
  - https://nhentai.net/api/galleries/search?query=chinese
  - https://nhentai.net/api/galleries/search?query=中国
- Thumbnails
  - https://t.nhentai.net/galleries/%s/thumb.%s

## Links for test

https://nhentai.net/api/galleries/search?query=-language:english%20-language:japanese
https://nhentai.net/search/?q=-language%3Aenglish+-language%3Ajapanese

- same with index
https://nhentai.net/search/?q=-

---

Perplexity api summary, asking: what api endpoint does nhentai has

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
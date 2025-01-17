.. default-role:: code

###########
 Changelog
###########

All notable changes to this project will be documented in this file.

The format is based on `Keep a Changelog`_, and this project adheres to
`Semantic Versioning`_.


[0.3.0] - 2022-10-08
####################

Changed
=======
- `LIBCMARK:NODE-GET-TITLE` returns a string instead of a pointer
- Type of `CMARK:NODE-LIST-TYPE` is now either `:CMARK-BULLET-LIST` or
  `:CMARK-ORDERED-LIST`, rather than `:BULLET-LIST` or `:ORDERED-LIST`
- Functions which used to signal `ERROR` now signal a more specific condition


Added
=====

- Preliminary manual
- Stream parser
- Proper export of symbols in the `cmark` package in accord with the manual
- Filled in missing docstrings
- Generic function `cmark:leaf-node-p`
- Conditions `parser-exhausted`, `orphan-node` and `child-node`


[0.2.0] - 2022-06-17
####################

Added
=====

- Streaming parser
- Parser keyword option `:smart` for smart text conversion, e.g. straight
  double quotes to proper English quotation marks


[0.1.0] - 2022-06-10
####################

Initial release.

.. _Keep a Changelog: https://keepachangelog.com/en/1.0.0/
.. _Semantic Versioning: https://semver.org/spec/v2.0.0.html

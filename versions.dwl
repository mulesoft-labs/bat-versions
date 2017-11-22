import * from bat::BDD
import * from bat::Assertions
---
describe `Bat versions` in [
  it must 'Version' in [
  GET `https://bat-analytics.devx.msap.io/v1/status` with {}
  ]
]
The following super metric was applied to Custom Groups \ Function, which has an instance that contains all Unified Access Gateway (UAG) members in an environment.  The purpose it to calculate the total number of sessions per environment (vROps 7.x/V4H 6.6 only has this value per UAG).
`sum({Unified Access Gateway: Summary|Total Session Count, depth=1})`

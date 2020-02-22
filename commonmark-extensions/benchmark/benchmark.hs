{-# LANGUAGE CPP                 #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE ScopedTypeVariables #-}
import Criterion.Main
import Data.Text (Text)
import Data.Functor.Identity  -- base >= 4.8
import Commonmark
import Commonmark.Extensions
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
#if !MIN_VERSION_base(4,11,0)
import Data.Monoid
#endif

main :: IO ()
main = do
  sample <- T.replicate 10 <$> TIO.readFile "benchmark/sample.md"
  defaultMainWith defaultConfig
    [ benchCommonmark (smartPunctuationSpec <> defaultSyntaxSpec)
        ("commonmark +smart", sample)
    , benchCommonmark (autolinkSpec <> defaultSyntaxSpec)
        ("commonmark +autolink", sample)
    , benchCommonmark (attributesSpec <> defaultSyntaxSpec)
        ("commonmark +attributes", sample)
    , benchCommonmark (defaultSyntaxSpec <> pipeTableSpec)
        ("commonmark +pipe_table", sample)
    ]

benchCommonmark :: SyntaxSpec Identity (Html ()) (Html ())
                -> (String, Text)
                -> Benchmark
benchCommonmark spec (name, contents) =
  bench name $
    nf (either (error . show) renderHtml
        . runIdentity . parseCommonmarkWith spec . tokenize name)
    contents


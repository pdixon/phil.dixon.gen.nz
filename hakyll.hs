{-# LANGUAGE OverloadedStrings #-}

import Prelude hiding (id)
import Control.Category (id)
import Control.Arrow (arr, (>>>), (***), second)
import Control.Monad (forM_)
import Data.Monoid (mempty, mconcat)
import qualified Data.Map as M

import Hakyll

main :: IO ()
main = hakyll $ do
    route   "css/*" idRoute
    compile "css/*" compressCssCompiler

    route   "js/*"  idRoute
    compile "js/*"  copyFileCompiler

    compile "templates/*" templateCompiler

    -- Index
    route  "index.html" idRoute
    create "index.html" $
        constA mempty
            >>> arr (setField "title" "Home")
            >>> arr (setField "section" "Home")
            >>> requireA "tags" (setFieldA "tagcloud" (renderTagCloud'))
            >>> requireAllA "posts/*" (id *** arr (take 5 . reverse . sortByBaseName) >>> addPostList)
            >>> applyTemplateCompiler "templates/index.html"
            >>> applyTemplateCompiler "templates/default.html"

    -- Post list
    route  "posts.html" idRoute
    create "posts.html" $
        constA mempty
            >>> arr (setField "title" "Posts")
            >>> requireAllA "posts/*" addPostList
            >>> applyTemplateCompiler "templates/posts.html"
            >>> applyTemplateCompiler "templates/default.html"

    -- Render each and every post
    route   "posts/*" $ setExtension ".html"
    compile "posts/*" $
        pageCompiler
            >>> arr (renderDateField "date" "%B %e, %Y" "Date unknown")
            >>> arr (setField "section" "Blog")
            >>> renderTagsField "prettytags" (fromCaptureString "tags/*")
            >>> applyTemplateCompiler "templates/post.html"
            >>> applyTemplateCompiler "templates/default.html"

    -- Render RSS feed
    route  "rss.xml" idRoute
    create "rss.xml" $
        requireAll_ "posts/*" >>> renderRss feedConfiguration

    -- Tags
    create "tags" $
        requireAll "posts/*" (\_ ps -> readTags ps :: Tags String)

    -- Add a tag list compiler for every tag
    route "tags/*" $ setExtension ".html"
    metaCompile $ require_ "tags"
        >>> arr (M.toList . tagsMap)
        >>> arr (map (\(t, p) -> (tagIdentifier t, makeTagList t p)))

    -- End
    return ()
   where
    renderTagCloud' :: Compiler (Tags String) String
    renderTagCloud' = renderTagCloud tagIdentifier 100 120

    tagIdentifier :: String -> Identifier
    tagIdentifier = fromCaptureString "tags/*"

addPostList :: Compiler (Page String, [Page String]) (Page String)
addPostList = setFieldA "posts" $
    arr (reverse . sortByBaseName)
        >>> require "templates/postitem.html" (\p t -> map (applyTemplate t) p)
        >>> arr mconcat
        >>> arr pageBody

makeTagList :: String
            -> [Page String]
            -> Compiler () (Page String)
makeTagList tag posts =
    constA (mempty, posts)
        >>> addPostList
        >>> arr (setField "title" ("Posts tagged " ++ tag))
        >>> applyTemplateCompiler "templates/posts.html"
        >>> applyTemplateCompiler "templates/default.html"

feedConfiguration :: FeedConfiguration
feedConfiguration = FeedConfiguration
    { feedTitle       = "Phillip Dixon"
    , feedDescription = "Personal blog of Phillip Dixon"
    , feedAuthorName  = "Phillip Dixon"
    , feedRoot        = "http://dixon.gen.nz"
    }

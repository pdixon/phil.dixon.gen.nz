{-# LANGUAGE OverloadedStrings #-}
module Main where

import Prelude hiding (id)
import Control.Category (id)
import Control.Arrow (arr, (>>>), (***), second)
import Control.Monad (forM_)
import Data.Monoid (mempty, mconcat)

import qualified Data.Map as M

import Hakyll

main :: IO ()
main = hakyll $ do
    match "css/*" $ do
          route idRoute
          compile compressCssCompiler

    match "js/*" $ do 
          route idRoute
          compile copyFileCompiler

    match "templates/*" $ do
          compile templateCompiler

    -- Index
    match "index.mdwn" $ do
          route $ setExtension "html"
          compile $ pageCompiler
            >>> requireAllA "posts/*" (id *** arr (take 5 . reverse . sortByBaseName) >>> addPostList)
            >>> applyTemplateCompiler "templates/index.html"
            >>> applyTemplateCompiler "templates/default.html"
    
    -- Static Pages
    forM_ ["about.mdwn", "projects.mdwn"] $ \page ->
        match page $ do
                  route $ setExtension "html"
                  compile $ pageCompiler
                     >>> applyTemplateCompiler "templates/default.html"

    -- Post list
    match  "posts.html" $ route idRoute
    create "posts.html" $ constA mempty
               >>> arr (setField "title" "Posts")
               >>> arr (setField "section" "Blog")
               >>> requireAllA "posts/*" addPostList
               >>> applyTemplateCompiler "templates/posts.html"
               >>> applyTemplateCompiler "templates/default.html"

    -- Render each and every post
    match "posts/*" $ do
                  route $ setExtension ".html"
                  compile $ pageCompiler
                        >>> arr (renderDateField "date" "%B %e, %Y" "Date unknown")
                        >>> arr (setField "section" "Blog")
                        >>> applyTemplateCompiler "templates/post.html"
                        >>> applyTemplateCompiler "templates/default.html"

    -- Render RSS feed
    match  "rss.xml" $ route idRoute
    create "rss.xml" $
        requireAll_ "posts/*" >>> renderRss feedConfiguration

addPostList :: Compiler (Page String, [Page String]) (Page String)
addPostList = setFieldA "posts" $
    arr (reverse . sortByBaseName)
        >>> require "templates/postitem.html" (\p t -> map (applyTemplate t) p)
        >>> arr mconcat
        >>> arr pageBody

feedConfiguration :: FeedConfiguration
feedConfiguration = FeedConfiguration
    { feedTitle       = "Phillip Dixon"
    , feedDescription = "Personal blog of Phillip Dixon"
    , feedAuthorName  = "Phillip Dixon"
    , feedRoot        = "http://phil.dixon.gen.nz"
    }

#!/bin/bash
git add .
git commit -s -m "update"
git push origin hexo
hexo clean
hexo g
hexo d
hexo clean

title=TODO title for resource-editor.md 
date=1900-01-01
type=post
tags=blog
status=published
~~~~~~
Title: The Apache Sling Resource Editor
Notice:    Licensed to the Apache Software Foundation (ASF) under one
           or more contributor license agreements.  See the NOTICE file
           distributed with this work for additional information
           regarding copyright ownership.  The ASF licenses this file
           to you under the Apache License, Version 2.0 (the
           "License"); you may not use this file except in compliance
           with the License.  You may obtain a copy of the License at
           .
             http://www.apache.org/licenses/LICENSE-2.0
           .
           Unless required by applicable law or agreed to in writing,
           software distributed under the License is distributed on an
           "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
           KIND, either express or implied.  See the License for the
           specific language governing permissions and limitations
           under the License.

![alt text][1]

Features
========
Currently it allows to display the node properties and edit nodes.

* Node editing includes adding, renaming and deleting nodes. 
* Multi selection of nodes, Keyboard controls for navigation and shortcuts are provided. Click on the info icon in the tree to get detailed information.
* The node names are HTML and URL encoded.
* The add node dialog provides you with the allowed node name / node type / resource type options and its combinations to prevent errors soon. Click on the info icon in the dialog to discover more.
* The nodes are bookmarkable.

Status
======
The features for the node tree are finished so far. Now the work on making properties editable begins.

Installation
============
1. Follow the [instructions for Getting and Building Sling][2].
1. The `contrib/explorers/resourceeditor/README` file in SVN tells you how to install the Resource Editor.
1. Open `http://localhost:8080/reseditor/.html` in your browser.
1. Enjoy!

  [1]: http://sling.apache.org/documentation/bundles/resource-editor-screenshot.png
  [2]: http://sling.apache.org/documentation/development/getting-and-building-sling.html

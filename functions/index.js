/**
 * Copyright 2017 Google Inc. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
'use strict';

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

// Cut off time. Child nodes older than this will be deleted.
const CUT_OFF_TIME = 24 * 60 * 60; // 24 Hours in seconds.

/**
 * This database triggered function will check for child nodes that are older than the
 * cut-off time. Each child needs to have a `timestamp` attribute.
 */
exports.deleteOldItems = functions.database.ref('/posts/{pushId}')
    .onCreate(event => {
      const ref = event.data.ref.parent; // reference to the items
      const now = Date.now()/1000|0;
      const cutoff = now - CUT_OFF_TIME;
      const oldItemsQuery = ref.orderByChild('time').endAt(cutoff);
      return oldItemsQuery.once('value').then(snapshot => {
        // create a map with all children that need to be removed
        const updates = {};
        snapshot.forEach(child => {
          updates[child.key] = null;
          ref.parent.child('/geoPosts/').child(child.key).remove();
        });
        // execute all updates in one go and return the result to end the function
        return ref.update(updates);
      });
    });
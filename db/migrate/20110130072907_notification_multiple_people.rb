class NotificationMultiplePeople < ActiveRecord::Migration
  def self.up
    create_table :notification_actors do |t|
        t.integer :notification_id
      t.integer :person_id
      t.timestamps
    end
    
    add_index :notification_actors, :notification_id
    add_index :notification_actors, [:notification_id, :person_id] , :unique => true
    add_index :notification_actors, :person_id  ## if i am not mistaken we don't need this one because we won't query person.notifications

    #make the notification actors table
    execute "INSERT INTO notification_actors (notification_id, person_id) " +
      " SELECT id , actor_id " +
      " FROM notifications"
    
    #update the notifications to reference the post
    execute "UPDATE notifications " +
              "SET " +
                "target_type = 'Post' " + 
              "WHERE (notifications.target_id in (select id from comments) " +
                "AND (notifications.action = 'comment_on_post' " +
                "OR notifications.action = 'also_commented'))"

    
    #select all the notifications to keep
    execute "CREATE TEMPORARY TABLE keep_table as " +
               "(SELECT id as keep_id, actor_id , target_type , target_id , recipient_id , action " +
               "FROM notifications WHERE action = 'comment_on_post' OR action = 'also_commented' )"
# +               "GROUP BY target_type , target_id , recipient_id , action) "

    #get a table of with ids of the notifications that need to be deleted and with the ones that need
    #to replace them
    execute "CREATE TEMPORARY TABLE keep_delete as" +
      "( SELECT n1.keep_id, n2.id as delete_id, " +
        "n2.actor_id, n1.target_type, n1.target_id, n1.recipient_id, n1.action " +
      "FROM keep_table n1, notifications n2 " +
      "WHERE n1.keep_id != n2.id " +
        "AND n1.actor_id != n2.actor_id "+
        "AND n1.target_type = n2.target_type AND n1.target_id = n2.target_id " +
        "AND n1.recipient_id = n2.recipient_id AND n1.action = n2.action " +
        "AND (n1.action = 'comment_on_post' OR n1.action = 'also_commented') )"
#+        "GROUP BY n2.actor_id , n2.target_type , n2.target_id , n2.recipient_id , n2.action)"

    #have the notifications actors reference the notifications that need to be kept
    execute "UPDATE notification_actors "+
              "SET notification_id = (select keep_id from keep_delete where delete_id = notification_id) "+
              "WHERE notification_id in (select delete_id from keep_delete)"

    #delete all the notifications that need to be deleted
    execute "DELETE  " +
              "FROM notifications " + 
              "WHERE notifications.id not in (select keep_id from  keep_delete where ( "+
                     "notifications.target_type = keep_delete.target_type AND "+
                     "notifications.target_id = keep_delete.target_id AND "+
                     "notifications.recipient_id = keep_delete.recipient_id AND "+
                     "notifications.action = keep_delete.action) )"


    remove_column :notifications, :actor_id
    remove_column :notifications, :mongo_id
  end

  def self.down
    remove_index :notification_actors, :notification_id
    remove_index :notification_actors, [:notification_id, :person_id]
    remove_index :notification_actors, :person_id
    
    drop_table :notification_actors
  end
end

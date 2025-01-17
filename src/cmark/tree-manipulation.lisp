;;;; Transformation of the node tree

(in-package #:cmark)

(defun unlink-node (node)
  "Unlinks a NODE from its parent, removing it from the node tree. Returns the
  node. The function is idempotent, i.e. unlinking a node without parent does
  nothing."
  (declare (type node node))
  (let ((parent (node-parent node)))
    (when parent
      (setf (slot-value node 'parent) nil)
      (with-slots (children) parent
        (setf children (delete node children :test #'eq))))
    node))

(defun insert-node-before (node sibling)
  "Inserts SIBLING into the tree in front of NODE. It is an error to insert
  before an orphan (signals ORPHAN-NODE), or to insert a node which is already
  a child (signals CHILD-NODE)."
  (insert-node node sibling #'insert-before))

(defun insert-node-after (node sibling)
  "Inserts SIBLING into the tree in front of NODE. It is an error to insert
  after an orphan (signals ORPHAN-NODE), or to insert a node which is already
  a child (signals CHILD-NODE)."
  (insert-node node sibling #'insert-after))

(defun replace-node (old-node new-node)
  "Replaces OLD-NODE with NEW-NODE and unlinks OLD-NODE from the tree."
  (declare (type node new-node old-node))
  (let ((parent (node-parent old-node)))
    (unless parent
      (error 'orphan-node :node old-node
             :format-control "Old node ~A has no parent node."
             :format-arguments (list old-node)))
    (setf (slot-value new-node 'parent) parent)
    (setf (slot-value old-node 'parent) nil)
    (with-slots (children) parent
      (setf children (nsubstitute new-node old-node children :test #'eq)))))

(defun prepend-child-node (node child)
  "Insert CHILD as the first child node of NODE. It is an error to prepend a
  node which is already a child of a node, signals CHILD-NODE."
  (when (node-parent child)
    (error 'child-node :node child
           :format-control "Node ~A is not an orphan node."
           :format-arguments (list child)))
  (setf (slot-value child 'parent) node)
  (push child (slot-value node 'children)))

(defun append-child-node (node child)
  "Append CHILD as the last child node of NODE. It is an error to append a node
  which is already a child of a node, signals CHILD-NODE."
  (when (node-parent child)
    (error 'child-node :node child
           :format-control "Node ~A is not an orphan node."
           :format-arguments (list child)))
  (setf (slot-value child 'parent) node)
  (setf (slot-value node 'children)
        (nconc (slot-value node 'children) (list child))))

(defun consolidate-text-nodes (root)
  (declare (type node root))
  "Consolidates adjacent text nodes in the tree starting at ROOT. Adjacent
  nodes of type TEXT-NODE will be merged into one by concatenating their
  literal text. Only one node will remain in the tree, the other nodes will
  become orphaned. It is undefined which node will remain in the tree."
  (let ((iterator (make-iterator root)))
    (do* ((event (iterator-event iterator) (iterator-event iterator))
          (current  (iterator-node iterator)  (iterator-node iterator))
          (next (node-next-sibling current) (node-next-sibling current)))
         ((eq event 'done) root)
      (if (and (eq event 'enter)
               (typep current 'text-node)
               (typep next 'text-node))
        ;; Accumulate text in the next node
        (progn
          (with-slots (literal) next
              (setf literal (concatenate 'string
                                       (node-literal current)
                                       literal)))
          ;; Make sure the iterator is not referencing the current node
          (iterator-advance iterator)
          (unlink-node current))
        (iterator-advance iterator)))))


;;; Helper functions
(defun insert-node (node sibling method)
  "Helper function, inserts SIBLING before or after NODE, depending on the
  METHOD."
  (declare (type node node sibling))
  (let ((parent (node-parent node)))
    (unless parent
      (error 'orphan-node :node node
           :format-control "Trying to add a sibling to orphan node ~A"
           :format-arguments (list node)))
    (when (node-parent sibling)
      (error 'child-node :node sibling
           :format-control "Trying to assign a parent to non-orphan node ~A"
           :format-arguments (list sibling)))
    (setf (slot-value sibling 'parent) parent)
    (with-slots (children) parent
      (setf children (funcall method
                              children
                              (position node children :test #'eq)
                              sibling))))
  t)

(defun insert-before (list i e)
  "Helper function"
  (declare (type list list)
           (type (integer 0) i)
           (type t e))
  (if (zerop i)
      (push e list)
      (push e (cdr (nthcdr (- i 1) list)))))

(defun insert-after (list i e)
  "Helper function"
  (declare (type list list)
           (type (integer 0) i)
           (type t e))
  (push e (cdr (nthcdr i list)))
  list)

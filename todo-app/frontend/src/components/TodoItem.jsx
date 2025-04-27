import React from 'react';
export default({todo,onToggle,onDelete})=>(<li><input type="checkbox" checked={todo.completed} onChange={onToggle}/><span style={{textDecoration:todo.completed?'line-through':''}}>{todo.text}</span><button onClick={onDelete}>Delete</button></li>);

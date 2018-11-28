import React, { Component } from 'react';

class App extends Component {
  get menuItems() {
    return [
      {id: 'stub-1', name: 'Item1'},
      {id: 'stub-2', name: 'Item2'},
      {id: 'stub-3', name: 'Item3'},
    ];
  }

  renderMenuItem(menuItem) {
    return <li key={menuItem.id}>{menuItem.name}</li>;
  }

  render() {
    return (
      <ul>
        {this.menuItems.map(item => this.renderMenuItem(item))}
      </ul>
    );
  }
}

export default App;

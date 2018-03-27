import * as React from "react";

class NonEmptyInput extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      editing: false,
      value: this.value()
    };
  }

  value() {
    return this.props[this.valueFieldName()]
  }

  editing() {
    return this.state.editing;
  }

  render() {
    if (this.editing()) {
      return this.renderEditView();
    } else {
      return this.renderDefaultView();
    }
  }

  onChange(e) {
    this.setState({value: e.target.value})
  }

  onBlur() {
    this.finishedEditing()
  }

  onKeyDown(e) {
    const code = e.keyCode;
    switch (code) {
      case 9: // Tab
        e.preventDefault();
        this.finishedEditing();
        return;
      case 13: // Enter
        this.finishedEditing();
        return;
      case 27: // Escape
        this.cancelEditing();
        return;
    }
  }

  onFocus(e) {
    e.target.select();
  }

  cancelEditing() {
    this.setState({
      editing: false,
      value: this.value()
    })
  }

  finishedEditing() {
    if (this.state.value) {
      this.setState({editing: false});
      this.props.onChange(this.state.value);
    } else {
      this.cancelEditing()
    }
  }

  renderEditView() {
    return this.renderInputComponent({
      value: this.state.value,
      onBlur: (e) => this.onBlur(e),
      onKeyDown: (e) => this.onKeyDown(e),
      onChange: (e) => this.onChange(e),
      onFocus: (e) => this.onFocus(e),
    })
  }

  renderInputComponent(inputProps) {
    let className = "form-group"
    let help = null;
    if (!this.state.value) {
      className += " has-error"
      help = <span className="help-block">required</span>
    }
    return <div className={className}>
      <input type="text" autoFocus className="form-control" {...inputProps} />
      { help }
    </div>
  }

  renderDefaultView() {
    const displayValue = this.state.value || <span>&nbsp;</span>;
    return <div className="editable" onClick={() => this.setState({editing: true})}>
      {displayValue}
    </div>;
  }
}

export default NonEmptyInput;

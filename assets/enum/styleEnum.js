class StyleEnum {
  constructor({
    siteStyle,
    sitePrefix,
  }) {
    this.siteStyle = siteStyle;
    this.sitePrefix = sitePrefix;
  }
}

StyleEnum.III = new StyleEnum({
  siteStyle: 1, sitePrefix: '',
});

StyleEnum.MOEA = new StyleEnum({
  siteStyle: 2, sitePrefix: 'MOEA',
});

const styleList = [StyleEnum.III, StyleEnum.MOEA];

const getStyleInfo = (style) => styleList.find((e) => e.siteStyle === style);

export default {};
export { getStyleInfo };

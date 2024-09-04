<template>
  <div class="layout">
    <div class="filter-bar" v-if="showFilterBar">
      <div class="title-container">
        <div class="title">
          <div class="title-img-box">
            <img :src="require('@/assets/img/common/icon-title.svg')" alt="" />
          </div>
          <p>
            <slot name="header-text" />
          </p>
        </div>
      </div>
      <slot name="filter" />
    </div>

    <div class="body">
      <slot />
    </div>
  </div>
</template>

<script>
export default {
  props: {
    btnText: {
      type: String,
      default: '',
    },
    showFilterBar: {
      type: Boolean,
      default: true,
    },
  },
  data() {
    return {};
  },
};
</script>

<style scoped lang="scss">
.layout {
  height: 100%;
  padding: 30px 120px 42px;
  background-color: #fff;
}

.filter-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 30px;

  .title-container {
    .title {
      display: flex;
      align-items: center;
      height: $el-input-height;
      color: #ffba31;
      font-weight: bolder;
      font-size: 1.375rem;
      letter-spacing: 2.2px;
    }
  }
}

.title-img-box {
  width: 16px;
  height: 18px;
  margin-right: 13px;

  img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
}
</style>

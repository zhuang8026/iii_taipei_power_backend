<template>
  <div class="item">
    <div class="image">
      <img
        :src="require(`@/assets/img/pages/download/${url}`)"
        alt=""
      />
    </div>
    <h2>{{ name }}</h2>
  </div>
</template>

<script>
export default {
  props: {
    name: {
      type: String,
      default: '',
    },
    url: {
      type: String,
      default: '',
    },
  },
};
</script>

<style lang="scss" scoped>
.item {
  text-align: center;
  cursor: pointer;

  .image {
    height: 12.0625rem;
    padding: 2.3rem 0;
    border-radius: 10px;
    background-color: #f5f5f5;
    box-shadow: 5px 5px 10px #00000029;

    img {
      width: 5.5rem;
      object-fit: cover;
    }
  }

  h2 {
    margin-top: 2rem;
    color: #333;
    font-size: 1.125rem;
    font-family: Noto Sans CJK TC, sans-serif;
  }
}
</style>

<template>
  <el-dialog v-loading="loading" title="刪除" :visible.sync="show" :before-close="reset">
    <el-form>
      <el-form-item>
        <p style="text-align: center;">確定刪除此筆資料</p>
      </el-form-item>
    </el-form>
    <span slot="footer" class="dialog-footer">
      <el-button @click="reset">取消</el-button>
      <el-button @click="deleteVersionInfo">確定</el-button>
    </span>
  </el-dialog>
</template>

<script>
import backendApi from '@/assets/js/api/backendApi.js';

export default {
  props: {
    value: {
      type: Boolean,
      default: false,
    },
    date: {
      type: String,
      default: '',
    },
  },
  data() {
    return {
      show: false,
      loading: false,
    };
  },
  watch: {
    value(val) {
      const vm = this;
      vm.show = val;
    },
    show(val) {
      const vm = this;
      vm.$emit('input', val);
    },
  },
  methods: {
    reset() {
      const vm = this;
      vm.show = false;
    },
    async deleteVersionInfo() {
      const vm = this;
      vm.loading = true;
      const res = await backendApi.deleteVersionInfo({ date: vm.date });
      if (res.code === 200) {
        vm.$emit('success');
        vm.reset();
      }
      vm.loading = false;
    },
  },
};
</script>
